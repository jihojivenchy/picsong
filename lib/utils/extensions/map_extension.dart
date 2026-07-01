extension MapExtension on Map<String, dynamic> {
  /// 값이 비어있지 않을 때만 Map에 추가
  void addIfNotEmpty(String key, String? value) {
    if (value != null && value.isNotEmpty) {
      this[key] = value;
    }
  }

  /// 값이 null이 아닐 때만 Map에 추가 (다른 타입용)
  void addIfNotNull(String key, dynamic value) {
    if (value != null) {
      this[key] = value;
    }
  }

  /// 값이 0이 아닐 때만 Map에 추가
  void addIfNotZero(String key, int value) {
    if (value != 0) {
      this[key] = value;
    }
  }

  /// 리스트가 null이 아니고 비어있지 않을 때만 Map에 추가
  void addIfNotEmptyList<T>(String key, List<T>? value) {
    if (value != null && value.isNotEmpty) {
      this[key] = value;
    }
  }
}
