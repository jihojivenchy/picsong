


/// 타임아웃 에러
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

/// 서버 에러
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// 토큰 누락 에러
class TokenMissingException implements Exception {
  final String message;
  TokenMissingException(this.message);

  @override
  String toString() => message;
}

/// 네트워크 에러
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
