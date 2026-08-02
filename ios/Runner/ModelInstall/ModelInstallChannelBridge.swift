//
//  ModelInstallChannelBridge.swift
//  Runner
//
//  모델 다운로드·설치 플랫폼 채널 브릿지.
//  - MethodChannel: Dart의 start/state 제어를 `ModelInstaller`로 전달
//  - EventChannel: `ModelInstaller`의 진행 스냅샷을 Dart로 스트리밍 (FlutterStreamHandler)
//

import Flutter

final class ModelInstallChannelBridge: NSObject {
    /// 제어 채널 — 등록 후 앱 생명주기 동안 보관한다
    private var methodChannel: FlutterMethodChannel?

    /// 진행률 채널 — 등록 후 앱 생명주기 동안 보관한다
    private var progressChannel: FlutterEventChannel?

    ///
    /// AppDelegate에서 호출 — Method/Event 두 채널을 등록한다.
    ///
    func register(messenger: FlutterBinaryMessenger) {
        let methodChannel = FlutterMethodChannel(
            name: AppChannel.ModelInstall.method,
            binaryMessenger: messenger
        )
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
        self.methodChannel = methodChannel

        let progressChannel = FlutterEventChannel(
            name: AppChannel.ModelInstall.progressEvents,
            binaryMessenger: messenger
        )
        progressChannel.setStreamHandler(self)
        self.progressChannel = progressChannel
    }

    /// 메서드 채널 호출 처리
    private func handle(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {

        // 다운로드·설치 시작 — 진행 중이거나 설치돼 있으면 설치자가 무시한다
        case AppChannel.ModelInstall.Method.start:
            ModelInstaller.shared.start()
            result(nil)

        // 현재 설치 상태 조회
        case AppChannel.ModelInstall.Method.state:
            result(ModelInstaller.shared.currentState().rawValue)

        // 그 외 (result를 무조건 한번은 호출해야하기 때문에 명시적으로 오류를 반환)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - FlutterStreamHandler
extension ModelInstallChannelBridge: FlutterStreamHandler {
    ///
    /// Dart가 구독을 시작하면 sink를 설치자에 연결한다. 연결 즉시 현재 스냅샷이 한 번 온다.
    ///
    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        ModelInstaller.shared.attachProgressHandler { payload in
            events(payload.toMap())
        }
        return nil
    }

    ///
    /// 구독 해지 — 연결을 끊는다.
    ///
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        ModelInstaller.shared.attachProgressHandler(nil)
        return nil
    }
}
