//
//  ModelInstallState.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import Foundation

/// 모델 설치 상태 — rawValue가 그대로 Dart의 ModelInstallState와 대응된다
enum ModelInstallState: String {
    case notInstalled
    case downloading
    case installing
    case ready
    case failed
}
