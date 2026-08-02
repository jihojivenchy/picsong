//
//  ModelProgressPayload.swift
//  Runner
//
//  네이티브 설치자가 EventChannel로 보내는 진행 스냅샷.
//  Dart `ModelInstallProgress`(model_install_progress.dart)와 1:1 대응하는 계약 —
//  `toMap()`의 키가 Dart 파서와 일치해야 한다.
//

import Foundation

struct ModelProgressPayload {
    /// 설치 상태
    let state: ModelInstallState

    /// 지금까지 확보한 바이트 수 — 진행률 분자
    let receivedBytes: Int64

    /// 전체 바이트 수 — manifest 수신 전이면 0
    let totalBytes: Int64

    ///
    /// EventChannel sink로 보낼 직렬화 형태
    ///
    func toMap() -> [String: Any] {
        [
            "state": state.rawValue,
            "receivedBytes": receivedBytes,
            "totalBytes": totalBytes,
        ]
    }
}
