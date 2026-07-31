/// 곡에서 클루로 출제되는 가사 한 줄.
class LyricLine {
  /// 가사 원문
  final String text;

  /// 이 가사를 그림으로 옮기기 위한 생성 프롬프트(영문)
  final String imagePrompt;

  const LyricLine({required this.text, required this.imagePrompt});

  ///
  /// JSON 한 줄을 가사 라인으로 변환
  ///
  factory LyricLine.fromJson(Map<String, dynamic> json) => LyricLine(
        text: json['text'] as String? ?? '',
        imagePrompt: json['imagePrompt'] as String? ?? '',
      );
}
