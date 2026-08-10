//
//  ClueChannelBridge.swift
//  Runner
//
//  온디바이스 클루 생성 플랫폼 채널 브릿지.
//  - MethodChannel: Dart의 generate 요청을 `ClueGenerator`로 전달
//

import Flutter

final class ClueChannelBridge {
    /// 생성을 직렬화하는 큐 — 동시 생성은 메모리를 두 배로 쓴다
    private let queue = DispatchQueue(label: "picsong.clue.generator", qos: .userInitiated)

    /// 생성 채널 — 등록 후 앱 생명주기 동안 보관한다
    private var channel: FlutterMethodChannel?

    ///
    /// AppDelegate에서 호출 — 메서드 채널을 등록한다.
    ///
    func register(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: AppChannel.Clue.method,
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
        self.channel = channel
    }

    /// 메서드 채널 호출 처리
    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == AppChannel.Clue.Method.generate else {
            result(FlutterMethodNotImplemented)
            return
        }
        let arguments: [String: Any]? = call.arguments as? [String: Any]
        guard let prompt = arguments?[AppChannel.Clue.Argument.prompt] as? String,
              let seed = arguments?[AppChannel.Clue.Argument.seed] as? Int else {
            result(FlutterError(code: "invalid_arguments", message: "prompt와 seed가 필요합니다", details: nil))
            return
        }
        generate(
            prompt: prompt,
            seed: UInt32(truncatingIfNeeded: seed),
            result: result
        )
    }

    /// 백그라운드에서 한 장 생성하고 파일 경로를 돌려준다.
    private func generate(prompt: String, seed: UInt32, result: @escaping FlutterResult) {
        queue.async {
            do {
                let url: URL = try ClueGenerator.generate(prompt: prompt, seed: seed)
                DispatchQueue.main.async { result(url.path) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "generation_failed", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
}
