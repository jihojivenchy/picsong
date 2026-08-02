//
//  NativeLog.swift
//  Runner
//

import Flutter

/// 네이티브 로그를 Dart로 넘겨 `flutter run` 터미널에 보이게 한다.
/// iOS 17+에서는 NSLog가 터미널로 전달되지 않아 Dart를 거쳐야 한다.
enum NativeLog {
    /// 로그 채널 이름 — Dart의 NativeLogBridge와 맞춘다
    private static let channelName: String = "picsong/native_log"

    /// Dart로 로그를 보내는 채널 — 메인 스레드에서만 읽고 쓴다
    private static var channel: FlutterMethodChannel?

    ///
    /// 채널을 연결한다. 앱 시작 시 메인 스레드에서 한 번 호출한다.
    ///
    static func configure(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
    }

    ///
    /// 한 줄을 남긴다 — 터미널(Dart)과 Console.app(NSLog) 양쪽에 남는다.
    /// 어느 스레드에서 불러도 되도록 채널 접근은 메인으로 넘긴다.
    ///
    static func write(_ message: String) {
        NSLog("%@", message)
        DispatchQueue.main.async { channel?.invokeMethod("log", arguments: message) }
    }
}
