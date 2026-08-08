/// 한 가사 줄을 쪼갠 클루 장면 하나.
class QuestionScene {
  /// 이 장면의 생성 프롬프트(영문)
  final String imagePrompt;

  /// 클루 이미지 생성 시드 — 같은 곡·같은 장면이면 항상 같은 그림
  final int imageSeed;

  const QuestionScene({required this.imagePrompt, required this.imageSeed});
}
