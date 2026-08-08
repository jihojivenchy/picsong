//
//  ModelInstallNotifier.swift
//  Runner
//
//  모델 설치 결과를 기기 로컬 알림으로 알린다.
//  앱이 백그라운드에 있어 진행률 화면이 없을 때가 이 파일의 존재 이유다.
//

import UIKit
import UserNotifications

/// 모델 설치 결과 알림 발송기 — 상태를 갖지 않는 발송 창구
enum ModelInstallNotifier {
    /// 알림 식별자 — 항상 같은 값을 써서 알림이 쌓이지 않고 최신 것으로 대체된다
    private static let identifier: String = "picsong.model.install.result"

    ///
    /// 알림 권한을 요청한다 — 다운로드를 시작하는 순간 부른다.
    /// 이미 응답한 사용자에게는 팝업이 다시 뜨지 않고, 거절해도 다운로드는 그대로 진행된다.
    ///
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            NSLog("%@", "[ModelInstallNotifier] 알림 권한 \(granted ? "허용" : "거부")")
        }
    }

    ///
    /// 설치 결과를 알린다 — 알릴 상태가 아니거나 앱이 화면에 떠 있으면 보내지 않는다.
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
    /// 상태별 알림 내용 — 알릴 가치가 없는 중간 상태는 nil을 돌려 발송을 막는다.
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
