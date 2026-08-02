import 'package:flutter/services.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/domain/entities/model_install/model_install_progress.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';

/// 모델 설치 채널 계약 — iOS `AppChannel.ModelInstall`(Runner/AppChannel.swift)과
/// 문자열이 정확히 일치해야 한다
abstract class _Channel {
  /// MethodChannel: Dart → 네이티브 제어(start/state)
  static const String method = 'picsong/model_installer';

  /// EventChannel: 네이티브 → Dart 진행 스냅샷 스트림
  static const String progressEvents = 'picsong/model_installer/progress';

  /// 다운로드·설치 시작
  static const String start = 'start';

  /// 현재 설치 상태 조회
  static const String state = 'state';
}

/// 온디바이스 모델 다운로드·설치 서비스
class ModelInstallService {
  /// 네이티브 설치자와 연결된 채널
  static const MethodChannel _channel = MethodChannel(_Channel.method);

  /// 진행률 이벤트 채널 — 구독 즉시 현재 스냅샷이 한 번 온다
  static const EventChannel _progressChannel =
      EventChannel(_Channel.progressEvents);

  ///
  /// 모델 다운로드·설치를 시작 — 진행 중이거나 설치돼 있으면 네이티브가 무시한다
  ///
  Future<void> startInstall() async {
    try {
      await _channel.invokeMethod<void>(_Channel.start);
    } on PlatformException catch (error) {
      throw ModelInstallException(error.message ?? '모델 다운로드를 시작하지 못했습니다');
    } on MissingPluginException {
      throw ModelInstallException('이 플랫폼은 모델 설치를 지원하지 않습니다');
    }
  }

  ///
  /// 현재 설치 상태 조회
  ///
  Future<ModelInstallState> fetchState() async {
    try {
      final String? raw = await _channel.invokeMethod<String>(_Channel.state);
      return ModelInstallState.fromQueryValue(raw);
    } on PlatformException catch (error) {
      throw ModelInstallException(error.message ?? '모델 상태를 확인하지 못했습니다');
    } on MissingPluginException {
      throw ModelInstallException('이 플랫폼은 모델 설치를 지원하지 않습니다');
    }
  }

  ///
  /// 진행 스냅샷 스트림
  ///
  Stream<ModelInstallProgress> progressStream() {
    return _progressChannel.receiveBroadcastStream().map(
          (Object? event) => ModelInstallProgress.fromJson(
            Map<String, dynamic>.from(event as Map<Object?, Object?>),
          ),
        );
  }
}
