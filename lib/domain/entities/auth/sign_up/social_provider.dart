


enum SocialProvider {
  none(queryValue: null),
  google(queryValue: 'GOOGLE'),
  kakao(queryValue: 'KAKAO'),
  naver(queryValue: 'NAVER'),
  apple(queryValue: 'APPLE');

  final String? queryValue;

  const SocialProvider({
    required this.queryValue,
  });

  factory SocialProvider.fromQueryValue(String? queryValue) {
    if (queryValue == null) {
      return SocialProvider.none;
    }
    
    return SocialProvider.values.firstWhere(
      (e) => e.queryValue == queryValue,
      orElse: () => SocialProvider.none,
    );
  }
}
