//
//  ModelManifest.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import Foundation

/// 허깅페이스 저장소의 manifest.json — 다운로드 목록·진행률 분모·검증 기준
struct ModelManifest: Codable {
    /// manifest 구조 버전
    let schemaVersion: Int

    /// 모델 버전 — 재다운로드 판단 기준
    let modelVersion: String

    /// 전체 바이트 수 — 진행률 분모
    let totalBytes: Int64

    /// 받을 파일 목록
    let files: [Entry]

    /// 받을 파일 한 건
    struct Entry: Codable {
        /// 저장소 루트 기준 상대 경로 (예: Unet.mlmodelc/weights/weight.bin)
        let path: String

        /// 파일 크기 — 설치 판정에 사용
        let bytes: Int64

        /// SHA-256 지문(소문자 hex) — 수신 직후 검증에 사용
        let sha256: String
    }

    ///
    /// [url]의 JSON 파일을 읽어 manifest로 해석한다.
    ///
    static func load(from url: URL) throws -> ModelManifest {
        let data: Data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ModelManifest.self, from: data)
    }
}
