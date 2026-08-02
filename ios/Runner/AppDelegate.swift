import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// 플랫폼 채널 모듈 — 앱 생명주기 동안 유지하기 위해 보관한다.
  private var clueBridge: ClueChannelBridge?
  private var modelInstallBridge: ModelInstallChannelBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerChannels()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// 백그라운드 다운로드 완료로 앱이 깨어날 때 — 완료 핸들러를 설치자에 맡긴다
  override func application(
    _ application: UIApplication,
    handleEventsForBackgroundURLSession identifier: String,
    completionHandler: @escaping () -> Void
  ) {
    guard identifier == ModelInstaller.sessionIdentifier else {
      super.application(
        application,
        handleEventsForBackgroundURLSession: identifier,
        completionHandler: completionHandler
      )
      return
    }
    ModelInstaller.shared.backgroundCompletionHandler = completionHandler
  }

  /// 플랫폼 채널 모듈을 등록한다 — 채널 이름·메서드 계약은 AppChannel이 소유한다.
  private func registerChannels() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let messenger: FlutterBinaryMessenger = controller.binaryMessenger

    let clueBridge = ClueChannelBridge()
    clueBridge.register(messenger: messenger)
    self.clueBridge = clueBridge

    let modelInstallBridge = ModelInstallChannelBridge()
    modelInstallBridge.register(messenger: messenger)
    self.modelInstallBridge = modelInstallBridge
  }
}
