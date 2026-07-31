/// 온보딩 스텝 (최초 1회) — 모델 다운로드까지 이어지는 4스텝
enum OnboardingStep {
  /// 게임 소개
  intro,

  /// 온디바이스 AI 설명 — 다음 스텝에서 요구할 1GB의 명분
  onDevice,

  /// 다운로드 안내 + 동의 (용량 고지 3종 필수)
  downloadGate,

  /// 모델 다운로드 진행 상태
  downloading;

  /// 상단 진행바 채움 비율
  double get progress => (index + 1) / values.length;

  /// 건너뛰기 노출 여부 — 다운로드가 시작되면 건너뛸 수 없다
  bool get canSkip => this != downloading;
}
