/// 회원가입 요청 엔티티
class SignUpRequest {
  final String signUpToken;

  /// 닉네임 (최대 10자)
  final String nickname;

  final bool marketingAgreed;

  final bool nightMarketingAgreed;

  const SignUpRequest({
    required this.signUpToken,
    required this.nickname,
    required this.marketingAgreed,
    required this.nightMarketingAgreed,
  });

  /// 초기 상태
  static SignUpRequest get initialState => const SignUpRequest(
        signUpToken: '',
        nickname: '',
        marketingAgreed: false,
        nightMarketingAgreed: false,
      );

  SignUpRequest copyWith({
    String? signUpToken,
    String? nickname,
    bool? marketingAgreed,
    bool? nightMarketingAgreed,
  }) {
    return SignUpRequest(
      nickname: nickname ?? this.nickname,
      signUpToken: signUpToken ?? this.signUpToken,
      marketingAgreed: marketingAgreed ?? this.marketingAgreed,
      nightMarketingAgreed: nightMarketingAgreed ?? this.nightMarketingAgreed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signupToken': signUpToken,
      'nickname': nickname,
      'marketingAgreed': marketingAgreed,
      'nightMarketingAgreed': nightMarketingAgreed,
    };
  }
}
