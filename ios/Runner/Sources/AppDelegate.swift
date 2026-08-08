import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// 플랫폼 채널 브릿지
  private var clueBridge: ClueChannelBridge?

  /// 모델 설치 채널 브릿지
  private var modelInstallBridge: ModelInstallChannelBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 플러터 플러그인 등록
    GeneratedPluginRegistrant.register(with: self)

    // 플랫폼 채널 등록
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

  /// 플랫폼 채널 모듈을 등록한다
  private func registerChannels() {
    // 루트 컨트롤러 조회
    guard let controller = window?.rootViewController as? FlutterViewController else { return }

    // 메시지 브로커 조회
    let messenger: FlutterBinaryMessenger = controller.binaryMessenger

    // 클루 채널 등록
    let clueBridge = ClueChannelBridge()
    clueBridge.register(messenger: messenger)
    self.clueBridge = clueBridge

    // 모델 설치 채널 등록
    let modelInstallBridge = ModelInstallChannelBridge()
    modelInstallBridge.register(messenger: messenger)
    self.modelInstallBridge = modelInstallBridge
  }
}
