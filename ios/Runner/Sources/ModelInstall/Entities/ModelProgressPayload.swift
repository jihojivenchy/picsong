//
//  ModelProgressPayload.swift
//  Runner
//

import Foundation

/// 진행률 페이로드
struct ModelProgressPayload {
    /// 설치 상태
    let state: ModelInstallState

    /// 지금까지 확보한 바이트 수 (진행률 분자)
    let receivedBytes: Int64    

    /// 전체 바이트 수 (진행률 분모)
    let totalBytes: Int64

    /// EventChannel sink로 보낼 직렬화 형태
    func toMap() -> [String: Any] {
        [
            "state": state.rawValue,
            "receivedBytes": receivedBytes,
            "totalBytes": totalBytes,
        ]
    }
}
