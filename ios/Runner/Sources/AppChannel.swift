//
//  AppChannel.swift
//  Runner
//
//  앱이 여는 모든 플랫폼 채널의 이름·메서드 계약.
//  Dart 측(ClueService·ModelInstallService)과 문자열이 정확히 일치해야 한다.
//

import Foundation

enum AppChannel {
    /// 온디바이스 클루 생성 — Dart `ClueService`(clue_service.dart)
    enum Clue {
        /// MethodChannel: Dart → 네이티브 생성 요청
        static let method: String = "picsong/clue_generator"

        /// Dart가 호출하는 메서드명
        enum Method {
            static let generate: String = "generate"
        }

        /// generate 호출 시 전달되는 인자 키
        enum Argument {
            static let prompt: String = "prompt"
            static let seed: String = "seed"
            /// 디노이징 스텝 수 — 선택값, 없으면 기본값을 쓴다
            static let steps: String = "steps"
        }
    }

    /// 모델 다운로드·설치
    enum ModelInstall {
        /// MethodChannel: Dart → 네이티브 제어(start/state)
        static let method: String = "picsong/model_installer"

        /// EventChannel: 네이티브 → Dart 진행 스냅샷 스트림
        static let progressEvents: String = "picsong/model_installer/progress"

        /// Dart가 호출하는 메서드명
        enum Method {
            static let start: String = "start"
            static let state: String = "state"
        }
    }
}
