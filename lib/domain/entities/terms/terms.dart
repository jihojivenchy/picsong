
/// 약관
class Terms {
  /// 약관 ID
  final int id;

  /// 약관 타입
  final TermAgreeType type;

  /// 약관 상세 내용
  final String content;

  /// 필수 여부
  final bool isRequired;

  const Terms({
    required this.id,
    required this.type,
    required this.content,
    required this.isRequired,
  });

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      id: json['id'] ?? -1,
      type: TermAgreeType.fromQueryValue(json['type'] ?? ''),
      content: json['content'] ?? '',
      isRequired: json['isRequired'] ?? false,
    );
  }
}


enum TermAgreeType {
  service(displayText: '서비스 이용약관', queryValue: 'SERVICE'),
  privacy(displayText: '개인정보처리방침', queryValue: 'PRIVACY'),
  location(displayText: '위치기반 서비스', queryValue: 'LOCATION_BASED'),
  marketing(displayText: '마케팅 정보 수신 동의', queryValue: 'MARKETING'),
  nightMarketing(displayText: '야간 마케팅 정보 수신 동의', queryValue: 'NIGHT_MARKETING');

  final String displayText;
  final String queryValue;

  const TermAgreeType({
    required this.displayText,
    required this.queryValue,
  });

  static TermAgreeType fromQueryValue(String? value) {
    if (value == null) return nightMarketing;
    
    return TermAgreeType.values.firstWhere(
      (e) => e.queryValue == value,
      orElse: () => nightMarketing,
    );
  }
}
