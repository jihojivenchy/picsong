import 'package:flutter/services.dart';
import 'package:picsong/utils/services/app_logger.dart';

/// 네이티브(iOS) 로그를 앱 로거로 넘겨받는 브리지
/// iOS 17+에서는 NSLog가 `flutter run` 터미널에 뜨지 않아 채널로 받아 찍는다
abstract class NativeLogBridge {
  /// 네이티브 로그 채널 — iOS NativeLog와 이름을 맞춘다
  static const MethodChannel _channel = MethodChannel('picsong/native_log');

  ///
  /// 네이티브 로그 수신을 시작 — 앱 시작 시 한 번 호출한다
  ///
  static void listen() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method != 'log') return;
      AppLogger.debug(call.arguments as String);
    });
  }
}
