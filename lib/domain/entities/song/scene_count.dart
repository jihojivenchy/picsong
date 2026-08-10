/// 한 가사 줄을 몇 장의 그림으로 표현하는지.
///
/// 한 장에는 요소 하나만 담기므로 가사 한 줄을 1~4장으로 쪼갠다.
/// 상한이 4인 이유는 장당 생성 시간(~2.2초)과 화면 높이 때문이다 —
/// 4장이면 문제당 ~8.8초이고, 두 줄(2×2)에 들어가는 것도 여기까지다.
enum SceneCount {
  one(value: 1),
  two(value: 2),
  three(value: 3),
  four(value: 4);

  /// 그림 장수
  final int value;

  const SceneCount({required this.value});

  ///
  /// 프롬프트 개수를 장수로 변환 (0장·5장 이상은 1장)
  ///
  factory SceneCount.fromValue(int value) {
    return SceneCount.values.firstWhere(
      (SceneCount count) => count.value == value,
      orElse: () => SceneCount.one,
    );
  }
}
