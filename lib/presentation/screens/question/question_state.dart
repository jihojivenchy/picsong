part of 'question_cubit.dart';

/// 퀴즈(문제 풀이) 화면 상태
final class QuestionState extends Equatable {
  /// 현재 문제 인덱스 (0-based)
  final int qIndex;

  /// 지금까지 공개된 클루 이미지 경로 목록 — 빈 문자열이면 생성 중
  final List<String> clueImagePathList;

  /// 현재 문제의 장면을 아직 그리는 중인지 — 다 그려지기 전에는 답안 공개를 막는다
  final bool isGeneratingScenes;

  /// 누적 오답 횟수 — 값이 아니라 늘어났다는 사실이 오답 1회를 뜻한다
  final int wrongAnswerCount;

  const QuestionState({
    this.qIndex = 0,
    this.clueImagePathList = const <String>[],
    this.isGeneratingScenes = false,
    this.wrongAnswerCount = 0,
  });

  QuestionState copyWith({
    int? qIndex,
    List<String>? clueImagePathList,
    bool? isGeneratingScenes,
    int? wrongAnswerCount,
  }) {
    return QuestionState(
      qIndex: qIndex ?? this.qIndex,
      clueImagePathList: clueImagePathList ?? this.clueImagePathList,
      isGeneratingScenes: isGeneratingScenes ?? this.isGeneratingScenes,
      wrongAnswerCount: wrongAnswerCount ?? this.wrongAnswerCount,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        qIndex,
        clueImagePathList,
        isGeneratingScenes,
        wrongAnswerCount,
      ];
}
