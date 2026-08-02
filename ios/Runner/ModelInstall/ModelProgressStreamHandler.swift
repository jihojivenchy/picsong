//
//  ModelProgressStreamHandler.swift
//  Runner
//
//  Created by 엄지호 on 8/2/26.
//

import Flutter

/// 진행률 EventChannel 핸들러 — Flutter sink를 ModelInstaller에 붙였다 뗀다
final class ModelProgressStreamHandler: NSObject, FlutterStreamHandler {
    ///
    /// Dart가 구독을 시작하면 sink를 설치자에 연결한다. 연결 즉시 현재 스냅샷이 한 번 온다.
    ///
    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        ModelInstaller.shared.attachProgressHandler { snapshot in
            events(snapshot)
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
