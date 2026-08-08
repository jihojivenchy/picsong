import 'package:picsong/domain/entities/song/scene_count.dart';

/// 곡에서 클루로 출제되는 가사 한 줄.
///
/// 한 장에는 요소 하나만 담기므로 한 줄을 1~3장으로 쪼개
/// **동시에** 보여준다. 플레이어는 그림들을 조합해 가사를 유추한다.
class LyricLine {
  /// 가사 원문
  final String text;

  /// 이 가사를 표현하는 그림 장수
  final SceneCount sceneCount;

  /// 이 가사를 쪼갠 장면별 생성 프롬프트(영문) — 표시 순서대로
  final List<String> imagePromptList;

  const LyricLine({
    required this.text,
    required this.sceneCount,
    required this.imagePromptList,
  });

  ///
  /// JSON 한 줄을 가사 라인으로 변환
  ///
  /// 프롬프트 개수로 장수를 확정하고 목록도 그 길이에 맞춘다 —
  /// 화면에 나오지 않을 장면을 생성하느라 시간을 쓰지 않기 위함이다.
  /// 프롬프트가 0개면 장수는 1장이 되지만 목록은 비어 있다. 그 줄은
  /// `RoundService`가 출제 대상에서 제외하므로 화면까지 오지 않는다.
  ///
  factory LyricLine.fromJson(Map<String, dynamic> json) {
    final List<String> promptList = _parseImagePromptList(json['imagePrompts']);
    final SceneCount sceneCount = SceneCount.fromValue(promptList.length);
    return LyricLine(
      text: json['text'] as String? ?? '',
      sceneCount: sceneCount,
      imagePromptList: promptList.take(sceneCount.value).toList(),
    );
  }

  /// 프롬프트 목록을 문자열 리스트로 변환, 실패 시 빈 목록 (순수)
  static List<String> _parseImagePromptList(Object? value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().where((String e) => e.isNotEmpty).toList();
  }
}
