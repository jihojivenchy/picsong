//
//  ModelInstaller.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import Foundation

/// 모델 다운로드·검증·설치를 담당하는 싱글톤
/// 백그라운드 다운로드를 위해 시스템 데몬을 이용하기 때문에 싱글톤으로 정의
final class ModelInstaller: NSObject {
    // MARK: - 프로퍼티
    /// 백그라운드 세션 식별자
    static let sessionIdentifier: String = "picsong.model.installer"

    /// 인스턴스
    static let shared: ModelInstaller = ModelInstaller()

    /// 모델 폴더 구조와 디스크 작업 담당
    let fileStore: ModelFileStore = ModelFileStore()

    /// iOS가 백그라운드 이벤트 전달 후 호출을 요구하는 완료 핸들러
    var backgroundCompletionHandler: (() -> Void)?


    // MARK: - 설치 상태

    /// 현재 상태 (델리게이트 큐에서만 변경)
    private var state: ModelInstallState = .notInstalled

    /// 이번 회차의 검증 기준 — 작업장의 manifest.json에서 복원된다
    private var manifest: ModelManifest?

    /// 파일별 누적 수신 바이트 — 진행률 분자 (키: 상대경로)
    var receivedBytes: [String: Int64] = [:]

    /// 파일별 재시도 횟수 (키: taskDescription)
    private var retryCounts: [String: Int] = [:]


    // MARK: - 진행률 발신

    /// 진행률 구독 핸들러 (델리게이트 큐에서만 접근)
    private var progressHandler: ((ModelProgressPayload) -> Void)?

    /// 마지막 진행률 전송 시각
    private var lastProgressAt: CFAbsoluteTime = 0

    // MARK: - 인프라

    /// 여러 파일로 인해 전달되는 콜백들을 단일 스레드에서 처리하기 위한 큐
    private let delegateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    /// 백그라운드 세션
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = .background(withIdentifier: Self.sessionIdentifier)

        // 시스템이 자동으로 다운로드를 관리하지 못하도록 처리
        configuration.isDiscretionary = false  

        // 세션 생성
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }()

    // MARK: - 생성자

    private override init() {
        super.init()
        restoreStateOnLaunch()
    }


    ///
    /// 다운로드 시작
    ///
    func start() {
        delegateQueue.addOperation { [self] in
            // 진행 중이거나 설치돼 있으면 중단
            guard state == .notInstalled || state == .failed else { return }

            // 알림 권한 요청
            ModelInstallNotifier.requestAuthorization()

            // 재시도 횟수 초기화
            retryCounts = [:]

            do {
                // 임시 디렉토리 준비
                try fileStore.prepareStagingDirectory()
            } catch {
                NSLog("%@", "[ModelInstaller] 작업장 준비 실패: \(error)")
                transition(to: .failed)
                return
            }

            // 다운로드 상태로 전환
            transition(to: .downloading)

            // 임시 디렉토리에서 manifest.json 로드 후 처리 (manifest.json은 어떤 파일들을 다운로드해야 하는지 적힌 목록표)
            if let staged: ModelManifest = fileStore.loadStagedManifest() {
                // 어느 파일부터 다운로드 받아야할지 체크하고 다운로드 등록
                adopt(staged)
            } else {
                // 다운로드 등록
                enqueueDownload(taskDescription: Download.manifestTag)
            }
        }
    }

    ///
    /// 현재 상태를 돌려준다
    ///
    func currentState() -> ModelInstallState {
        // 스냅샷 생성
        var snapshot: ModelInstallState = .notInstalled

        // 현재 상태 읽기
        let read: BlockOperation = BlockOperation { snapshot = self.state }

        // 큐에 추가하고 대기
        delegateQueue.addOperations([read], waitUntilFinished: true)

        // 스냅샷 반환
        return snapshot
    }

    ///
    /// 진행률 구독자를 붙이거나(핸들러) 뗀다(nil). 붙는 즉시 현재 스냅샷을 한 번 보낸다.
    ///
    func attachProgressHandler(_ handler: ((ModelProgressPayload) -> Void)?) {
        delegateQueue.addOperation { [self] in
            progressHandler = handler
            emitProgress(force: true)
        }
    }
}

// MARK: - 설치 흐름
extension ModelInstaller {
    ///
    /// 앱 시작 시 디스크와 세션에서 상태를 복원한다 — 상태의 근거는 항상 파일이다
    ///
    private func restoreStateOnLaunch() {
        delegateQueue.addOperation { [self] in
            if fileStore.isInstalled() {
                state = .ready
                NSLog("%@", "[ModelInstaller] 설치 확인됨")
            } else if let staged: ModelManifest = fileStore.loadStagedManifest() {
                manifest = staged
                receivedBytes = fileStore.stagedBytes(of: staged)
            }
        }
        session.getAllTasks { [self] tasks in
            guard !tasks.isEmpty, state != .ready else { return }
            state = .downloading
            NSLog("%@", "[ModelInstaller] 진행 중 전송 \(tasks.count)건 재연결")
        }
    }

    ///
    /// manifest를 기준으로 어떤 파일들을 더 받아야하는지 결정하고 다운로드 등록
    ///
    private func adopt(_ manifest: ModelManifest) {
        // manifest 저장 (기준점)
        self.manifest = manifest

        // 이미 저장되어있는 파일들의 바이트 수를 계산하여 진행률에 반영
        receivedBytes = fileStore.stagedBytes(of: manifest)

        // 새로 다운로드 받아야할 파일들 필터링
        let pending: [ModelManifest.Entry] = manifest.files.filter { !fileStore.isStaged($0) }

        // 새로 다운로드 받아야할 파일이 없으면 설치 완료 처리
        guard !pending.isEmpty else {
            finalizeInstall()
            return
        }

        // 남은 파일들의 바이트 수 계산
        let requiredBytes: Int64 = pending.reduce(0) { $0 + $1.bytes } + Download.diskSpaceMargin

        // 디스크 공간 체크
        guard fileStore.availableDiskSpace() > requiredBytes else {
            NSLog("%@", "[ModelInstaller] 저장 공간 부족 — \(requiredBytes) bytes 필요")
            transition(to: .failed)
            return
        }

        // 남은 파일들을 다운로드 등록
        pending.forEach { enqueueDownload(taskDescription: $0.path) }
    }

    ///
    /// 다운로드 등록
    ///
    private func enqueueDownload(taskDescription: String) {
        // 파일 경로 생성 (manifest.json은 따로 처리)
        let relativePath: String =
            taskDescription == Download.manifestTag ? ModelFileStore.manifestFileName : taskDescription

        // 다운로드 작업 생성
        let task: URLSessionDownloadTask =
            session.downloadTask(with: Download.repoBase.appending(path: relativePath))

        // 작업 설명 설정
        task.taskDescription = taskDescription

        // 시작
        task.resume()
    }
}

// MARK: - 수신 파일 처리
extension ModelInstaller {
    ///
    /// 받은 manifest를 검증 및 저장하고, 나머지 파일들 다운로드 시작
    ///
    func adoptDownloadedManifest(at url: URL) throws {
        let downloaded: ModelManifest = try fileStore.stageManifest(from: url)
        NSLog("%@", "[ModelInstaller] manifest 수신 — \(downloaded.files.count)개 파일, \(downloaded.totalBytes) bytes")
        adopt(downloaded)
    }

    ///
    /// 지문을 검증하고 임시 디렉토리에 저장
    ///
    func verifyAndStage(_ file: URL, entryPath: String) throws {
        // 다운로드 받은 파일이 Manifest에 존재하는 파일인지 확인
        guard let entry: ModelManifest.Entry = manifest?.files.first(where: { $0.path == entryPath }) else {
            throw ModelInstallerError.unknownFile(path: entryPath)
        }

        // 검증 시작
        try fileStore.stage(file, as: entry)

        // 진행률 저장
        receivedBytes[entryPath] = entry.bytes

        
        emitProgress(force: true)
        if let manifest: ModelManifest = manifest, manifest.files.allSatisfy(fileStore.isStaged) {
            finalizeInstall()
        }
    }

    ///
    /// 임시 디렉토리를 완성본 디렉토리로 승격 (설치 완료)
    ///
    private func finalizeInstall() {
        // 설치 상태 전환
        transition(to: .installing)

        do {
            // 임시 디렉토리를 완성본 디렉토리로 승격
            try fileStore.promoteStaging()

            // 모델 준비 상태 전환
            transition(to: .ready)
            NSLog("%@", "[ModelInstaller] 설치 완료")
        } catch {
            NSLog("%@", "[ModelInstaller] 설치 확정 실패: \(error)")
            transition(to: .failed)
        }
    }
}

// MARK: - 재시도
extension ModelInstaller {
    ///
    /// 같은 파일을 resolve 루트부터 다시 받는다. 재시도 소진이면 실패로 전환하고 남은 전송을 멈춘다.
    ///
    func scheduleRetry(for tag: String) {
        retryCounts[tag, default: 0] += 1
        guard retryCounts[tag, default: 0] <= Download.maxRetryCount else {
            NSLog("%@", "[ModelInstaller] \(tag) 재시도 소진")
            transition(to: .failed)
            session.getAllTasks { tasks in tasks.forEach { $0.cancel() } }
            return
        }
        enqueueDownload(taskDescription: tag)
    }
}

// MARK: - 상태·진행률 발신
extension ModelInstaller {
    /// 상태를 바꾸고 즉시 알린다 — 백그라운드라면 로컬 알림으로도 알린다
    private func transition(to newState: ModelInstallState) {
        state = newState
        emitProgress(force: true)
        ModelInstallNotifier.notify(state: newState)
    }

    ///
    /// 진행률 스냅샷을 구독자에게 보낸다. [force]가 아니면 최소 간격으로 묶는다.
    ///
    func emitProgress(force: Bool) {
        // Core Foundation 시각 타입. 2001년 1월 1일 0시부터 몇 초 흘렀는지를 담은 숫자 (Double)
        let now: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

        // forece가 true 거나 or 마지막으로 보낸 뒤 0.2초가 지났는지 여부
        guard force || now - lastProgressAt >= Progress.minInterval else { return }
        lastProgressAt = now
        guard let handler: (ModelProgressPayload) -> Void = progressHandler else { return }
        let snapshot: ModelProgressPayload = ModelProgressPayload(
            state: state,
            receivedBytes: receivedBytes.values.reduce(0, +),
            totalBytes: manifest?.totalBytes ?? 0
        )
        DispatchQueue.main.async { handler(snapshot) }
    }
}

// MARK: - 상수
extension ModelInstaller {
    /// 다운로드 원천과 정책
    enum Download {
        /// 허깅페이스 저장소 (서명된 주소는 1시간이면 만료되어서 매번 새로 요청해야 함)
        static let repoBase: URL =
            URL(string: "https://huggingface.co/jivenchy/sd-turbo-coreml-384-6bit/resolve/main")!

        /// manifest 태스크를 파일 태스크와 구분하는 taskDescription 값
        static let manifestTag: String = "__manifest__"

        /// 파일당 최대 재시도 횟수
        static let maxRetryCount: Int = 3

        /// 설치에 요구하는 여유 공간 마진 (200MB)
        static let diskSpaceMargin: Int64 = 200 * 1024 * 1024
    }

    /// 진행률 전송
    enum Progress {
        /// 전송 최소 간격(초) (0.2초)
        static let minInterval: CFAbsoluteTime = 0.2
    }
}
