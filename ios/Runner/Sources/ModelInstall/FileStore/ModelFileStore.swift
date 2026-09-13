//
//  ModelFileStore.swift
//  Runner
//
//  모델 폴더 구조(models/·models.tmp/)와 디스크 작업 담당. 설치 상태는 모른다.
//

import CryptoKit
import Foundation

struct ModelFileStore {
    /// manifest 파일 이름 — 저장소와 로컬 모두 이 이름을 쓴다
    static let manifestFileName: String = "manifest.json"

    /// 처리 중인 수신 파일에 붙는 접두사 — 중단으로 남은 찌꺼기를 청소할 때 식별한다
    private static let incomingPrefix: String = "incoming-"

    /// 완성 모델 폴더
    var modelDirectory: URL { supportDirectory.appending(path: "models") }

    /// 다운로드 임시 폴더 (전부 검증이 완료되면 models로 승격)
    var stagingDirectory: URL { supportDirectory.appending(path: "models.tmp") }

    /// Application Support (Caches에 두면 시스템이 지울 수 있기 때문에 해당 배치)
    private var supportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    // MARK: - 조회

    ///
    /// models/manifest.json 기준으로 파일의 존재·크기를 대조한다.
    /// 해시 재검증은 안 한다 — models는 전부 검증된 뒤에만 생기는 폴더다 (원자적 rename)
    ///
    func isInstalled() -> Bool {
        guard let manifest: ModelManifest = try? ModelManifest.load(
            from: modelDirectory.appending(path: Self.manifestFileName)
        ) else { return false }
        return manifest.files.allSatisfy { entry in
            fileSize(at: modelDirectory.appending(path: entry.path)) == entry.bytes
        }
    }

    /// 임시 디렉토리에 이미 검증되어 저장된 파일인가? (새로 다운로드 받아야할 파일인지 확인)
    func isStaged(_ entry: ModelManifest.Entry) -> Bool {
        fileSize(at: stagingDirectory.appending(path: entry.path)) == entry.bytes
    }

    /// 임시 디렉토리에 저장된 파일들의 바이트 맵 — 진행률 분자의 초기값
    func stagedBytes(of manifest: ModelManifest) -> [String: Int64] {
        Dictionary(uniqueKeysWithValues: manifest.files.filter(isStaged).map { ($0.path, $0.bytes) })
    }

    ///
    /// manifest 조회
    ///
    func loadStagedManifest() -> ModelManifest? {
        try? ModelManifest.load(from: stagingDirectory.appending(path: Self.manifestFileName))
    }

    /// 디스크 공간 체크
    func availableDiskSpace() -> Int64 {
        let values: URLResourceValues? = try? supportDirectory.resourceValues(
            forKeys: [.volumeAvailableCapacityForImportantUsageKey]
        )
        return values?.volumeAvailableCapacityForImportantUsage ?? 0
    }

    // MARK: - 배치

    ///
    /// 임시 디렉토리 준비
    ///
    func prepareStagingDirectory() throws {
        try FileManager.default.createDirectory(at: stagingDirectory, withIntermediateDirectories: true)
        try excludeFromBackup(stagingDirectory)
        try FileManager.default.contentsOfDirectory(at: stagingDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix(Self.incomingPrefix) }
            .forEach { try FileManager.default.removeItem(at: $0) }
    }

    /// 처리 중인 수신 파일을 잠시 둘 임시 경로
    func makeIncomingURL() -> URL {
        stagingDirectory.appending(path: "\(Self.incomingPrefix)\(UUID().uuidString)")
    }

    ///
    /// 받은 manifest를 검증하고 임시 디렉토리에 저장
    ///
    func stageManifest(from url: URL) throws -> ModelManifest {
        // 파싱
        let downloaded: ModelManifest = try ModelManifest.load(from: url)

        // 스키마 버전 확인
        guard downloaded.schemaVersion == 1 else {
            throw ModelInstallerError.unsupportedManifest(downloaded.schemaVersion)
        }

        //  정식 manifest 경로 생성
        let destination: URL = stagingDirectory.appending(path: Self.manifestFileName)

        // 이미 존재하는 파일이 있을 경우 -> 제거
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        // 익명 파일에 정식 이름 제공
        try FileManager.default.moveItem(at: url, to: destination)
        return downloaded
    }

    ///
    /// 지문을 검증하고 임시 디렉토리의 제 위치로 옮긴다.
    ///
    func stage(_ file: URL, as entry: ModelManifest.Entry) throws {
        // 해시 대조
        guard try sha256(of: file) == entry.sha256.lowercased() else {
            throw ModelInstallerError.checksumMismatch(path: entry.path)
        }

        // 경로상에 존재하는 중간 루트들을 생성
        let destination: URL = stagingDirectory.appending(path: entry.path)
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // 이미 파일 존재하면 제거
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        // 타겟 파일 위치로 이동
        try FileManager.default.moveItem(at: file, to: destination)
    }

    ///
    /// 작업장을 rename 한 번으로 완성본으로 승격한다 — 전부 검증된 뒤에만 불린다.
    ///
    func promoteStaging() throws {
        if FileManager.default.fileExists(atPath: modelDirectory.path) {
            try FileManager.default.removeItem(at: modelDirectory)
        }
        try FileManager.default.moveItem(at: stagingDirectory, to: modelDirectory)
        try excludeFromBackup(modelDirectory)
    }

    // MARK: - private

    /// 파일 크기 — 없으면 -1
    private func fileSize(at url: URL) -> Int64 {
        let attributes: [FileAttributeKey: Any]? = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? Int64) ?? -1
    }

    ///
    /// 파일의 SHA-256 지문을 계산
    /// SHA-256: 데이터의 지문을 만드는 해시 알고리즘
    ///
    private func sha256(of url: URL) throws -> String {
        // 해시 계산기 생성
        var hasher: SHA256 = SHA256()

        // 파일을 읽기 모드로 열기
        let handle: FileHandle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        // 4MB씩 읽어서 해시 계산
        // 큰 파일을 한 번에 읽으면 메모리에 부담이 크기 때문에 4MB씩 읽어서 해시 계산
        // hasher는 각 조각을 순서대로 누적해서 최종 계산함
        while let chunk: Data = try handle.read(upToCount: 4 * 1024 * 1024), !chunk.isEmpty {
            hasher.update(data: chunk)
        }

        // 최종 SHA-256 결과 반환
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    /// iCloud 백업 제외 (심사 거부 사유)
    private func excludeFromBackup(_ url: URL) throws {
        var target: URL = url
        var values: URLResourceValues = URLResourceValues()
        values.isExcludedFromBackup = true
        try target.setResourceValues(values)
    }
}
