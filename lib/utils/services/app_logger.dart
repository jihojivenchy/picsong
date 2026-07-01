import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

/// 앱 전역 로거 (Talker 기반)
abstract class AppLogger {
  static final Talker _talker = Talker(
    settings: TalkerSettings(
      enabled: kDebugMode,
      useConsoleLogs: true,
    ),
  );

  /// Talker 인스턴스 (DioLogger 등 외부 연동용)
  static Talker get talker => _talker;

  /// 일반 로그
  static void log(String message) {
    _talker.log(message);
  }

  /// 정보 로그
  static void info(String message) {
    _talker.info(message);
  }

  /// 경고 로그
  static void warning(String message) {
    _talker.warning(message);
  }

  /// 에러 로그
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _talker.error(message, error, stackTrace);
  }

  /// 디버그 로그
  static void debug(String message) {
    _talker.debug(message);
  }
}
