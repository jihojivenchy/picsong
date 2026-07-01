/// 게임이 다루는 음악 시대(1980~2020년대).
enum Era {
  era80s(id: '80s', label: '1980년대', watermark: '80'),
  era90s(id: '90s', label: '1990년대', watermark: '90'),
  era00s(id: '00s', label: '2000년대', watermark: '00'),
  era10s(id: '10s', label: '2010년대', watermark: '10'),
  era20s(id: '20s', label: '2020년대', watermark: '20');

  /// 시대 식별자 (예: '80s')
  final String id;

  /// 시대 표기 (예: '1980년대')
  final String label;

  /// 카드 워터마크 숫자 (예: '80')
  final String watermark;

  const Era({
    required this.id,
    required this.label,
    required this.watermark,
  });
}
