//
//  ModelInstallState.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import Foundation

/// 모델 설치 상태
enum ModelInstallState: String {
    // 설치되지 않은 상태
    case notInstalled

    // 다운로드 중인 상태
    case downloading

    // 설치 중인 상태
    case installing

    // 설치 완료 상태
    case ready

    // 설치 실패 상태
    case failed
}
