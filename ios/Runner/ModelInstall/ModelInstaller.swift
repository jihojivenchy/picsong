//
//  ModelInstaller.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import CryptoKit
import Foundation

/// 모델 다운로드·검증·설치를 소유하는 싱글톤.
/// 상태의 소유자는 이 객체다 — Dart는 조회·표시만 한다.
final class ModelInstaller: NSObject {
    // MARK: 상수

    /// 백그라운드 세션 식별자 — 앱 재실행 시 같은 값으로 만들어야 진행 중 전송을 되찾는다
    static let sessionIdentifier: String = "picsong.model.installer"

    /// 저장소 resolve 루트 — CDN 주소를 만들 수 있는 유일한 곳. 서명 주소는 1시간이면 죽는다
    private static let repoBase: URL =
        URL(string: "https://huggingface.co/jivenchy/sd-turbo-coreml-384-6bit/resolve/main")!

    /// manifest 태스크를 파일 태스크와 구분하는 taskDescription 값
    private static let manifestTag: String = "__manifest__"

    /// manifest 파일 이름 — 저장소와 로컬 모두 이 이름을 쓴다
    private static let manifestFileName: String = "manifest.json"

    /// 파일당 최대 재시도 횟수 — 소진하면 실패로 전환
    private static let maxRetryCount: Int = 3

    /// 설치에 요구하는 여유 공간 마진
    private static let diskSpaceMargin: Int64 = 200 * 1024 * 1024

    /// 진행률 전송 최소 간격(초) — 채널을 밀어내지 않는다
    private static let progressInterval: CFAbsoluteTime = 0.2

    static let shared: ModelInstaller = ModelInstaller()

    // MARK: 프로퍼티

    /// iOS가 백그라운드 이벤트 전달 후 호출을 요구하는 완료 핸들러 — AppDelegate가 넣어준다
    var backgroundCompletionHandler: (() -> Void)?

    /// 완성 모델 폴더 — ClueGenerator가 여기서 읽게 된다
    var modelDirectory: URL { supportDirectory.appending(path: "models") }

    /// 진행률 구독자(Flutter EventChannel sink) — 델리게이트 큐에서만 접근한다
    private var progressHandler: ((ModelProgressPayload) -> Void)?

    /// 현재 상태 — 델리게이트 큐에서만 변경한다
    private var state: ModelInstallState = .notInstalled

    /// 이번 회차의 검증 기준 — 작업장의 manifest.json에서 복원된다
    private var manifest: ModelManifest?

    /// 파일별 누적 수신 바이트 — 진행률 분자 (키: 상대경로)
    private var receivedBytes: [String: Int64] = [:]

    /// 파일별 재시도 횟수 (키: taskDescription)
    private var retryCounts: [String: Int] = [:]

    /// 마지막 진행률 전송 시각
    private var lastProgressAt: CFAbsoluteTime = 0

    /// 다운로드·검증 작업장 — 전부 검증된 뒤에야 models로 승격된다
    private var stagingDirectory: URL { supportDirectory.appending(path: "models.tmp") }

    /// Application Support — Caches와 달리 시스템이 지우지 않는다
    private var supportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    /// 모든 델리게이트 콜백과 상태 변경을 직렬화하는 큐
    private let delegateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    /// 백그라운드 세션 — 전송의 실소유자는 시스템 데몬이라 앱이 죽어도 계속 받는다
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = .background(withIdentifier: Self.sessionIdentifier)
        configuration.isDiscretionary = false
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }()

    // MARK: 생성자

    private override init() {
        super.init()
        restoreStateOnLaunch()
    }

    // MARK: public

    ///
    /// 다운로드를 시작한다. 진행 중이거나 설치돼 있으면 아무것도 하지 않는다.
    ///
    func start() {
        delegateQueue.addOperation { [self] in
            guard state == .notInstalled || state == .failed else { return }
            retryCounts = [:]
            do {
                try prepareStagingDirectory()
            } catch {
                NSLog("%@", "[ModelInstaller] 작업장 준비 실패: \(error)")
                transition(to: .failed)
                return
            }
            transition(to: .downloading)
            if let staged: ModelManifest = loadStagedManifest() {
                adopt(staged)
            } else {
                enqueueDownload(taskDescription: Self.manifestTag)
            }
        }
    }

    ///
    /// 현재 상태를 돌려준다 — 델리게이트 큐와 직렬화해 읽는다.
    ///
    func currentState() -> ModelInstallState {
        var snapshot: ModelInstallState = .notInstalled
        let read: BlockOperation = BlockOperation { snapshot = self.state }
        delegateQueue.addOperations([read], waitUntilFinished: true)
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

    // MARK: private

    ///
    /// 앱 시작 시 디스크와 세션에서 상태를 복원한다 — 상태의 근거는 항상 파일이다
    ///
    private func restoreStateOnLaunch() {
        delegateQueue.addOperation { [self] in
            if isInstalled() {
                state = .ready
                NSLog("%@", "[ModelInstaller] 설치 확인됨")
            } else if let staged: ModelManifest = loadStagedManifest() {
                manifest = staged
                receivedBytes = stagedBytes(of: staged)
            }
        }
        session.getAllTasks { [self] tasks in
            guard !tasks.isEmpty, state != .ready else { return }
            state = .downloading
            NSLog("%@", "[ModelInstaller] 진행 중 전송 \(tasks.count)건 재연결")
        }
    }

    ///
    /// manifest를 이번 회차의 기준으로 삼고, 작업장에 없는 파일의 다운로드를 등록한다.
    ///
    private func adopt(_ manifest: ModelManifest) {
        self.manifest = manifest
        receivedBytes = stagedBytes(of: manifest)
        let pending: [ModelManifest.Entry] = manifest.files.filter { !isStaged($0) }
        guard !pending.isEmpty else {
            finalizeInstall()
            return
        }
        let requiredBytes: Int64 = pending.reduce(0) { $0 + $1.bytes } + Self.diskSpaceMargin
        guard availableDiskSpace() > requiredBytes else {
            NSLog("%@", "[ModelInstaller] 저장 공간 부족 — \(requiredBytes) bytes 필요")
            transition(to: .failed)
            return
        }
        pending.forEach { enqueueDownload(taskDescription: $0.path) }
    }

    ///
    /// [taskDescription]이 가리키는 파일의 백그라운드 다운로드를 등록한다.
    /// URL은 항상 resolve 루트에서 새로 만든다 — 해석된 CDN 주소를 저장하지 않는다
    ///
    private func enqueueDownload(taskDescription: String) {
        let relativePath: String =
            taskDescription == Self.manifestTag ? Self.manifestFileName : taskDescription
        let task: URLSessionDownloadTask =
            session.downloadTask(with: Self.repoBase.appending(path: relativePath))
        task.taskDescription = taskDescription
        task.resume()
    }

    ///
    /// 작업장 폴더를 만들고 백업 제외를 걸고, 처리 중 중단으로 남은 임시 파일을 청소한다.
    ///
    private func prepareStagingDirectory() throws {
        try FileManager.default.createDirectory(at: stagingDirectory, withIntermediateDirectories: true)
        try excludeFromBackup(stagingDirectory)
        try FileManager.default.contentsOfDirectory(at: stagingDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("incoming-") }
            .forEach { try FileManager.default.removeItem(at: $0) }
    }

    ///
    /// models/manifest.json 기준으로 파일의 존재·크기를 대조한다.
    /// 해시 재검증은 안 한다 — models는 전부 검증된 뒤에만 생기는 폴더다 (원자적 rename)
    ///
    private func isInstalled() -> Bool {
        guard let manifest: ModelManifest = try? ModelManifest.load(
            from: modelDirectory.appending(path: Self.manifestFileName)
        ) else { return false }
        return manifest.files.allSatisfy { entry in
            fileSize(at: modelDirectory.appending(path: entry.path)) == entry.bytes
        }
    }

    /// 작업장에 이미 검증돼 놓인 파일인가 — 도착 시점에 해시를 통과한 파일만 놓인다
    private func isStaged(_ entry: ModelManifest.Entry) -> Bool {
        fileSize(at: stagingDirectory.appending(path: entry.path)) == entry.bytes
    }

    /// 작업장에 확보된 파일들의 바이트 맵 — 진행률 분자의 초기값
    private func stagedBytes(of manifest: ModelManifest) -> [String: Int64] {
        Dictionary(uniqueKeysWithValues: manifest.files.filter(isStaged).map { ($0.path, $0.bytes) })
    }

    /// 작업장의 manifest — 있으면 이전 회차가 어디까지 왔는지의 기준
    private func loadStagedManifest() -> ModelManifest? {
        try? ModelManifest.load(from: stagingDirectory.appending(path: Self.manifestFileName))
    }

    /// 파일 크기 — 없으면 -1
    private func fileSize(at url: URL) -> Int64 {
        let attributes: [FileAttributeKey: Any]? = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? Int64) ?? -1
    }

    /// iCloud 백업 제외 — 누락은 심사 거부 사유다
    private func excludeFromBackup(_ url: URL) throws {
        var target: URL = url
        var values: URLResourceValues = URLResourceValues()
        values.isExcludedFromBackup = true
        try target.setResourceValues(values)
    }

    /// 이 볼륨에서 지금 쓸 수 있는 바이트 수
    private func availableDiskSpace() -> Int64 {
        let values: URLResourceValues? = try? supportDirectory.resourceValues(
            forKeys: [.volumeAvailableCapacityForImportantUsageKey]
        )
        return values?.volumeAvailableCapacityForImportantUsage ?? 0
    }
}

// MARK: - 수신 파일 처리
private extension ModelInstaller {
    ///
    /// 받은 manifest를 채택한다 — 작업장에 저장해 앱이 죽어도 검증 기준이 남게 한다.
    ///
    func adoptDownloadedManifest(at url: URL) throws {
        let downloaded: ModelManifest = try ModelManifest.load(from: url)
        guard downloaded.schemaVersion == 1 else {
            throw ModelInstallerError.unsupportedManifest(downloaded.schemaVersion)
        }
        let destination: URL = stagingDirectory.appending(path: Self.manifestFileName)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: url, to: destination)
        NSLog("%@", "[ModelInstaller] manifest 수신 — \(downloaded.files.count)개 파일, \(downloaded.totalBytes) bytes")
        adopt(downloaded)
    }

    ///
    /// 지문을 검증하고 작업장의 제 위치로 옮긴다. 마지막 파일이면 설치를 확정한다.
    ///
    func verifyAndStage(_ file: URL, entryPath: String) throws {
        guard let entry: ModelManifest.Entry = manifest?.files.first(where: { $0.path == entryPath }) else {
            throw ModelInstallerError.unknownFile(path: entryPath)
        }
        guard try sha256(of: file) == entry.sha256.lowercased() else {
            throw ModelInstallerError.checksumMismatch(path: entryPath)
        }
        let destination: URL = stagingDirectory.appending(path: entryPath)
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: file, to: destination)
        receivedBytes[entryPath] = entry.bytes
        emitProgress(force: true)
        if let manifest: ModelManifest = manifest, manifest.files.allSatisfy(isStaged) {
            finalizeInstall()
        }
    }

    ///
    /// 전부 검증된 뒤에만 불린다 — 작업장을 rename 한 번으로 완성본으로 승격한다
    ///
    func finalizeInstall() {
        transition(to: .installing)
        do {
            if FileManager.default.fileExists(atPath: modelDirectory.path) {
                try FileManager.default.removeItem(at: modelDirectory)
            }
            try FileManager.default.moveItem(at: stagingDirectory, to: modelDirectory)
            try excludeFromBackup(modelDirectory)
            transition(to: .ready)
            NSLog("%@", "[ModelInstaller] 설치 완료")
        } catch {
            NSLog("%@", "[ModelInstaller] 설치 확정 실패: \(error)")
            transition(to: .failed)
        }
    }

    ///
    /// 같은 파일을 resolve 루트부터 다시 받는다. 재시도 소진이면 실패로 전환하고 남은 전송을 멈춘다.
    ///
    func scheduleRetry(for tag: String) {
        retryCounts[tag, default: 0] += 1
        guard retryCounts[tag, default: 0] <= Self.maxRetryCount else {
            NSLog("%@", "[ModelInstaller] \(tag) 재시도 소진")
            transition(to: .failed)
            session.getAllTasks { tasks in tasks.forEach { $0.cancel() } }
            return
        }
        enqueueDownload(taskDescription: tag)
    }

    /// 상태를 바꾸고 즉시 알린다
    func transition(to newState: ModelInstallState) {
        state = newState
        emitProgress(force: true)
    }

    ///
    /// 진행률 스냅샷을 구독자에게 보낸다. [force]가 아니면 최소 간격으로 묶는다.
    ///
    func emitProgress(force: Bool) {
        let now: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        guard force || now - lastProgressAt >= Self.progressInterval else { return }
        lastProgressAt = now
        guard let handler: (ModelProgressPayload) -> Void = progressHandler else { return }
        let snapshot: ModelProgressPayload = ModelProgressPayload(
            state: state,
            receivedBytes: receivedBytes.values.reduce(0, +),
            totalBytes: manifest?.totalBytes ?? 0
        )
        DispatchQueue.main.async { handler(snapshot) }
    }

    ///
    /// 파일의 SHA-256을 스트리밍으로 계산한다 — 620MB를 메모리에 올리지 않는다.
    ///
    func sha256(of url: URL) throws -> String {
        var hasher: SHA256 = SHA256()
        let handle: FileHandle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        while let chunk: Data = try handle.read(upToCount: 4 * 1024 * 1024), !chunk.isEmpty {
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - URLSessionDownloadDelegate
extension ModelInstaller: URLSessionDownloadDelegate {
    ///
    /// 다운로드 완료 — 이 콜백이 리턴되면 location의 파일이 삭제되므로 동기적으로 옮긴다.
    ///
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        guard let tag: String = downloadTask.taskDescription else { return }
        guard let response = downloadTask.response as? HTTPURLResponse, response.statusCode == 200 else {
            let statusCode: Int = (downloadTask.response as? HTTPURLResponse)?.statusCode ?? -1
            NSLog("%@", "[ModelInstaller] \(tag) HTTP \(statusCode)")
            scheduleRetry(for: tag)
            return
        }
        let holding: URL = stagingDirectory.appending(path: "incoming-\(UUID().uuidString)")
        do {
            try FileManager.default.moveItem(at: location, to: holding)
            if tag == Self.manifestTag {
                try adoptDownloadedManifest(at: holding)
            } else {
                try verifyAndStage(holding, entryPath: tag)
            }
        } catch {
            NSLog("%@", "[ModelInstaller] \(tag) 처리 실패: \(error)")
            try? FileManager.default.removeItem(at: holding)
            scheduleRetry(for: tag)
        }
    }

    ///
    /// 바이트 수신 진행 — 진행률 분자를 갱신한다.
    ///
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let tag: String = downloadTask.taskDescription, tag != Self.manifestTag else { return }
        receivedBytes[tag] = totalBytesWritten
        emitProgress(force: false)
    }

    ///
    /// 태스크 종료 — 성공 처리는 didFinishDownloadingTo가 끝냈으므로 에러만 본다.
    ///
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error: Error = error, let tag: String = task.taskDescription else { return }
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        NSLog("%@", "[ModelInstaller] \(tag) 전송 실패: \(error.localizedDescription)")
        scheduleRetry(for: tag)
    }

    ///
    /// 백그라운드 이벤트 전달 완료 — 보관해둔 완료 핸들러를 불러줘야 다음에도 앱을 깨워준다.
    ///
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            backgroundCompletionHandler?()
            backgroundCompletionHandler = nil
        }
    }
}
