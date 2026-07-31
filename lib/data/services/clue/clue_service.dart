import 'package:flutter/services.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';

/// 온디바이스 클루 이미지 생성 서비스
class ClueService {
  /// 네이티브 생성기와 연결된 채널 — iOS AppDelegate와 이름을 맞춘다
  static const MethodChannel _channel = MethodChannel('picsong/clue_generator');

  /// 모든 클루에 공통으로 붙는 화풍 프리픽스 — 이미지 프롬프트 규칙
  static const String _stylePrefix =
      'muted gouache painting, flat plain background, desaturated palette, '
      'soft even light, Korean, black hair, ';

  ///
  /// 가사 장면([scene]) 묘사로 클루 이미지를 생성하고 저장된 로컬 파일 경로를 반환
  ///
  Future<String> generateClueImage({
    required String scene,
    required int seed,
  }) async {
    try {
      final String? path = await _channel.invokeMethod<String>(
        'generate',
        <String, dynamic>{'prompt': '$_stylePrefix$scene', 'seed': seed},
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
