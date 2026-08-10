/// 게임이 다루는 음악 시대(1980~2020년대).
enum Era {
  era8090s(
    id: '8090s',
    label: '80~90년대',
    watermark: '8090',
    queryValue: '8090s',
  ),
  era00s(id: '00s', label: '2000년대', watermark: '00', queryValue: '2000s'),
  era10s(id: '10s', label: '2010년대', watermark: '10', queryValue: '2010s'),
  era20s(id: '20s', label: '2020년대', watermark: '20', queryValue: '2020s');

  /// 시대 식별자 (예: '8090s')
  final String id;

  /// 시대 표기 (예: '80~90년대')
  final String label;

  /// 카드 워터마크 숫자 (예: '8090')
  final String watermark;

  /// songs.json의 era 값 (예: '8090s')
  final String queryValue;

  const Era({
    required this.id,
    required this.label,
    required this.watermark,
    required this.queryValue,
  });

  ///
  /// songs.json의 era 문자열을 시대로 변환 (미상이면 80~90년대)
  ///
  factory Era.fromQueryValue(String? value) {
    if (value == null) return Era.era8090s;
    return Era.values.firstWhere(
      (Era era) => era.queryValue == value,
      orElse: () => Era.era8090s,
    );
  }
}
