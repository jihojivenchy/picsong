//
//  ModelInstallNotifier.swift
//  Runner
//
//  모델 설치 결과를 기기 로컬 알림으로 알린다.
//  앱이 백그라운드에 있어 진행률 화면이 없을 때가 이 파일의 존재 이유다.
//

import UIKit
import UserNotifications

/// 모델 설치 결과 알림 발송기
enum ModelInstallNotifier {
    /// 알림 식별자
    private static let identifier: String = "picsong.model.install.result"

    ///
    /// 알림 권한을 요청
    ///
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            NSLog("%@", "[ModelInstallNotifier] 알림 권한 \(granted ? "허용" : "거부")")
        }
    }

    ///
    /// 설치 결과를 알림으로 발송
    ///
    static func notify(state: ModelInstallState) {
        guard let content: UNNotificationContent = makeContent(for: state) else { return }
        DispatchQueue.main.async {
            guard UIApplication.shared.applicationState != .active else { return }
            let request: UNNotificationRequest = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    ///
    /// 상태별 알림 내용
    ///
    private static func makeContent(for state: ModelInstallState) -> UNNotificationContent? {
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        switch state {
        case .ready:
            content.title = "다운로드가 완료되었습니다"
            content.body = "이제 게임을 시작해볼까요?"
        case .failed:
            content.title = "다운로드에 실패했어요"
            content.body = "앱을 열어 다시 시도해 주세요."
        default:
            return nil
        }
        content.sound = .default
        return content
    }
}
