import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// 클루 생성 채널 이름 — Dart의 ClueService와 맞춘다
  private static let clueChannelName = "picsong/clue_generator"

  /// 모델 설치 채널 이름 — Dart의 ModelInstallService와 맞춘다
  private static let modelInstallChannelName = "picsong/model_installer"

  /// 모델 설치 진행률 이벤트 채널 이름
  private static let modelProgressChannelName = "picsong/model_installer/progress"

  /// 생성을 직렬화하는 큐 — 동시 생성은 메모리를 두 배로 쓴다
  private let clueQueue = DispatchQueue(label: "picsong.clue.generator", qos: .userInitiated)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    configureNativeLog()
    registerClueChannel()
    registerModelInstallChannels()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// 네이티브 로그를 Dart로 넘길 채널을 연결한다 — 다른 등록보다 먼저 한다.
  private func configureNativeLog() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    NativeLog.configure(binaryMessenger: controller.binaryMessenger)
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

  /// 온디바이스 클루 생성을 Dart에 노출한다.
  private func registerClueChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(
      name: Self.clueChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "generate" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let arguments = call.arguments as? [String: Any],
            let prompt = arguments["prompt"] as? String,
            let seed = arguments["seed"] as? Int else {
        result(FlutterError(code: "invalid_arguments", message: "prompt와 seed가 필요합니다", details: nil))
        return
      }
      self?.generateClue(prompt: prompt, seed: UInt32(truncatingIfNeeded: seed), result: result)
    }
  }

  /// 모델 다운로드·설치를 Dart에 노출한다 — 시작·상태 조회와 진행률 스트림.
  private func registerModelInstallChannels() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(
      name: Self.modelInstallChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "start":
        ModelInstaller.shared.start()
        result(nil)
      case "state":
        result(ModelInstaller.shared.currentState().rawValue)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    let progressChannel = FlutterEventChannel(
      name: Self.modelProgressChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    progressChannel.setStreamHandler(ModelProgressStreamHandler())
  }

  /// 백그라운드에서 한 장 생성하고 파일 경로를 돌려준다.
  private func generateClue(prompt: String, seed: UInt32, result: @escaping FlutterResult) {
    clueQueue.async {
      do {
        let url = try ClueGenerator.generate(prompt: prompt, seed: seed)
        DispatchQueue.main.async { result(url.path) }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "generation_failed", message: error.localizedDescription, details: nil))
        }
      }
    }
  }
}
