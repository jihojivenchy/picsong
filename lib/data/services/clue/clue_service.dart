import 'package:flutter/services.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';

/// 클루 생성 채널 계약 — iOS `AppChannel.Clue`(Runner/AppChannel.swift)와
/// 문자열이 정확히 일치해야 한다
abstract class _Channel {
  /// MethodChannel: Dart → 네이티브 생성 요청
  static const String method = 'picsong/clue_generator';

  /// 클루 이미지 한 장 생성
  static const String generate = 'generate';

  /// generate 호출 시 전달하는 인자 키
  static const String promptArgument = 'prompt';
  static const String seedArgument = 'seed';
}

/// 온디바이스 클루 이미지 생성 서비스
class ClueService {
  /// 네이티브 생성기와 연결된 채널
  static const MethodChannel _channel = MethodChannel(_Channel.method);

  /// 모든 클루에 공통으로 붙는 화풍 프리픽스 — 3토큰을 넘기지 않는다
  ///
  /// 실기기 실측(2026-08-03): 프리픽스가 21토큰이던 시절 핵심 명사가 34번째로
  /// 밀려 전부 누락됐다. 앞 7토큰 안에 들어와야 그려진다.
  static const String _stylePrefix = 'gouache painting, ';

  ///
  /// 가사 장면([scene]) 묘사로 클루 이미지를 생성하고 저장된 로컬 파일 경로를 반환
  ///
  Future<String> generateClueImage({
    required String scene,
    required int seed,
  }) async {
    try {
      final String? path = await _channel.invokeMethod<String>(
        _Channel.generate,
        <String, dynamic>{
          _Channel.promptArgument: '$_stylePrefix$scene',
          _Channel.seedArgument: seed,
        },
      );
      if (path == null || path.isEmpty) {
        throw ClueGenerationException('클루 이미지 경로를 받지 못했습니다');
      }
      return path;
    } on PlatformException catch (error) {
      throw ClueGenerationException(error.message ?? '클루 이미지 생성에 실패했습니다');
    } on MissingPluginException {
      throw ClueGenerationException('이 플랫폼은 온디바이스 생성을 지원하지 않습니다');
    }
  }

  ///
  /// 프롬프트 실험용 — [prompt]를 화풍 프리픽스 없이 그대로 보내고 [steps]를 지정한다
  ///
  /// 프리픽스·스텝의 영향을 실기기에서 가리기 위한 진단 경로다.
  /// 원인 규명이 끝나면 프롬프트 실험실 화면과 함께 제거한다.
  ///
  Future<String> generateRawImage({
    required String prompt,
    required int seed,
    required int steps,
  }) async {
    try {
      final String? path = await _channel.invokeMethod<String>(
        'generate',
        <String, dynamic>{'prompt': prompt, 'seed': seed, 'steps': steps},
      );
      if (path == null || path.isEmpty) {
        throw ClueGenerationException('클루 이미지 경로를 받지 못했습니다');
      }
      return path;
    } on PlatformException catch (error) {
      throw ClueGenerationException(error.message ?? '클루 이미지 생성에 실패했습니다');
    } on MissingPluginException {
      throw ClueGenerationException('이 플랫폼은 온디바이스 생성을 지원하지 않습니다');
    }
  }
}
