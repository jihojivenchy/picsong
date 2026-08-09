part of 'prompt_lab_cubit.dart';

/// 프롬프트 실험실 화면 상태
final class PromptLabState extends Equatable {
  /// 실험 결과 목록 — 생성될 때마다 해당 항목이 교체된다
  final List<PromptTrial> trialList;

  /// 실행 중 여부
  final bool isRunning;

  /// 완료된 건수
  final int doneCount;

  const PromptLabState({
    this.trialList = const <PromptTrial>[],
    this.isRunning = false,
    this.doneCount = 0,
  });

  PromptLabState copyWith({
    List<PromptTrial>? trialList,
    bool? isRunning,
    int? doneCount,
  }) {
    return PromptLabState(
      trialList: trialList ?? this.trialList,
      isRunning: isRunning ?? this.isRunning,
      doneCount: doneCount ?? this.doneCount,
    );
  }

  @override
  List<Object?> get props => <Object?>[trialList, isRunning, doneCount];
}
