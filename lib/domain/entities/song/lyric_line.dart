import 'package:picsong/domain/entities/song/scene_count.dart';

/// 곡에서 출제되는 가사 줄
class LyricLine {
  /// 가사 원문
  final List<String> textList;

  /// 이 가사를 표현하는 그림 개수
  final SceneCount sceneCount;

  /// 이 가사를 쪼갠 개별 생성 프롬프트
  final List<String> imagePromptList;

  const LyricLine({
    required this.textList,
    required this.sceneCount,
    required this.imagePromptList,
  });

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    // 이미지 프롬프트 파싱
    final List<String> promptList = _parseStringList(json['imagePrompts']);

    // 그림 개수 파싱
    final SceneCount sceneCount = SceneCount.fromValue(promptList.length);

    return LyricLine(
      textList: _parseStringList(json['textList']),
      sceneCount: sceneCount,
      imagePromptList:
          promptList.take(sceneCount.value).toList(), // 그림 개수만큼 프롬프트 저장
    );
  }

  /// 문자열 목록으로 변환
  static List<String> _parseStringList(Object? value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().where((String e) => e.isNotEmpty).toList();
  }
}
