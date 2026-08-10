/// 힌트 시트에 한 줄로 표시되는 항목.
class Hint {
  /// 왼쪽에 놓이는 라벨 (예: '가수 초성')
  final String label;

  /// 오른쪽에 놓이는 값
  final String value;

  const Hint({required this.label, required this.value});

  ///
  /// songs.json의 힌트 한 건을 엔티티로 변환
  ///
  factory Hint.fromJson(Map<String, dynamic> json) => Hint(
        label: json['label'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );
}
