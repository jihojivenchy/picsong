/// 모델 설치 상태 — iOS `ModelInstallState`의 rawValue와 대응된다
enum ModelInstallState {
  /// 설치 안 됨 (최초 또는 삭제됨)
  notInstalled(queryValue: 'notInstalled'),

  /// 다운로드 중
  downloading(queryValue: 'downloading'),

  /// 검증 완료 후 설치(원자적 이동) 중
  installing(queryValue: 'installing'),

  /// 사용 가능
  ready(queryValue: 'ready'),

  /// 실패 (재시도 소진·공간 부족 등)
  failed(queryValue: 'failed');

  /// 채널로 주고받는 문자열 값
  final String queryValue;

  const ModelInstallState({required this.queryValue});

  factory ModelInstallState.fromQueryValue(String? value) {
    if (value == null) return ModelInstallState.notInstalled;
    return ModelInstallState.values.firstWhere(
      (ModelInstallState e) => e.queryValue == value,
      orElse: () => ModelInstallState.notInstalled,
    );
  }
}
