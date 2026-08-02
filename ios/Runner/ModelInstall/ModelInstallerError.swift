//
//  ModelInstallerError.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import Foundation

/// 설치 실패 원인
enum ModelInstallerError: Error {
    /// 지원하지 않는 manifest 구조 버전
    case unsupportedManifest(Int)
    /// 받은 파일의 SHA-256이 manifest와 다르다
    case checksumMismatch(path: String)
    /// manifest에 없는 파일이 도착했다
    case unknownFile(path: String)
}
