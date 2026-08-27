


/// 온디바이스 클루 이미지 생성 에러
class ClueGenerationException implements Exception {
  final String message;
  ClueGenerationException(this.message);

  @override
  String toString() => message;
}

/// 온디바이스 모델 다운로드·설치 에러
class ModelInstallException implements Exception {
  final String message;
  ModelInstallException(this.message);

  @override
  String toString() => message;
}

/// 곡 데이터(songs.json) 적재 에러
class SongDataException implements Exception {
  final String message;
  SongDataException(this.message);

  @override
  String toString() => message;
}
