import 'package:picsong/data/dtos/auth/token_response_dto.dart';

/// 회원가입 완료 응답 DTO
class SignUpResponseDTO {
  final TokenResponseDTO accessToken;
  final TokenResponseDTO refreshToken;

  const SignUpResponseDTO({
    required this.accessToken,
    required this.refreshToken,
  });

  factory SignUpResponseDTO.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return SignUpResponseDTO(
      accessToken: TokenResponseDTO.fromJson(result['accessToken']),
      refreshToken: TokenResponseDTO.fromJson(result['refreshToken']),
    );
  }
}
