import 'package:picsong/data/dtos/auth/token_response_dto.dart';

class SignInResponseDTO {
  final UserAuthStatus status;
  final TokenResponseDTO? accessToken;
  final TokenResponseDTO? refreshToken;
  final String signUpToken;

  const SignInResponseDTO({
    required this.status,
    required this.accessToken,
    required this.refreshToken,
    required this.signUpToken,
  });

  factory SignInResponseDTO.fromJson(Map<String, dynamic> json) {
    final result = json['result'];

    return SignInResponseDTO(
      status: UserAuthStatus.fromQueryValue(result['status'] ?? ''),
      signUpToken: result['signupToken'] ?? '',
      accessToken: result['accessToken'] != null
          ? TokenResponseDTO.fromJson(result['accessToken'])
          : null,
      refreshToken: result['refreshToken'] != null
          ? TokenResponseDTO.fromJson(result['refreshToken'])
          : null,
    );
  }
}

///
/// 유저 상태
///
enum UserAuthStatus {
  normal(queryValue: 'LOGIN_SUCCESS'),
  notRegistered(queryValue: 'NEED_SIGNUP');

  final String queryValue;

  const UserAuthStatus({
    required this.queryValue,
  });

  factory UserAuthStatus.fromQueryValue(String? value) {
    if (value == null) {
      return UserAuthStatus.notRegistered;
    }

    return UserAuthStatus.values.firstWhere(
      (e) => e.queryValue == value,
      orElse: () => UserAuthStatus.notRegistered,
    );
  }
}
