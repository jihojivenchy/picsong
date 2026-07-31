import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// 클루 생성 채널 이름 — Dart의 ClueService와 맞춘다
  private static let clueChannelName = "picsong/clue_generator"

  /// 생성을 직렬화하는 큐 — 동시 생성은 메모리를 두 배로 쓴다
  private let clueQueue = DispatchQueue(label: "picsong.clue.generator", qos: .userInitiated)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerClueChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
