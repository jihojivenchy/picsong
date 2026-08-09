import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/song/scene_count.dart';
import 'package:picsong/presentation/common/base/base_cubit_screen.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:picsong/presentation/screens/question/viewmodel/question_cubit.dart';
import 'package:picsong/presentation/screens/question/widgets/hint_bottom_sheet.dart';
import 'package:picsong/presentation/screens/question/widgets/question_actions.dart';
import 'package:picsong/presentation/screens/question/widgets/question_input_bar.dart';
import 'package:picsong/presentation/screens/question/widgets/question_progress.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/question_scene_view.dart';

/// 퀴즈(문제 풀이) 화면
class QuestionScreen extends BaseCubitScreen<QuestionCubit> {
  /// 진행할 시대
  final Era era;

  /// 이번 라운드의 문제 목록
  final List<Question> questionList;

  /// 로딩 화면에서 미리 생성해둔 1번 문제 이미지 경로
  final String firstImagePath;

  const QuestionScreen({
    super.key,
    required this.era,
    required this.questionList,
    required this.firstImagePath,
  });

  /// 뷰모델 생성 — 미리 뽑아둔 첫 장면 뒤를 이어서 채운다
  @override
  QuestionCubit createViewModel(BuildContext context) {
    return QuestionCubit(questionList: questionList)
      ..generateScenes(firstImagePath: firstImagePath);
  }

  /// 닫기(X) + 가운데 시대명
  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: era.label,
      centerTitle: true,
      titleColor: AppColors.textStrong,
      backButtonType: BackButtonType.xmark,
      backButtonColor: AppColors.black,
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    // 오답 1회를 입력바에 알리는 신호. 값이 아니라 "바뀌었다"는 알림 자체가 의미다.
    final ValueNotifier<int> wrongAnswerSignal = useValueNotifier<int>(0);

    return BlocListener<QuestionCubit, QuestionState>(
      listenWhen: (QuestionState previous, QuestionState current) =>
          previous.wrongAnswerCount != current.wrongAnswerCount,
      listener: (BuildContext context, QuestionState state) =>
          wrongAnswerSignal.value++,
      child: Column(
        children: <Widget>[
          Expanded(child: _buildQuestionArea(context)),
          _buildInputBar(context, wrongAnswerSignal: wrongAnswerSignal),
        ],
      ),
    );
  }

  /// 진행도부터 보조 액션까지, 스크롤되는 문제 영역
  Widget _buildQuestionArea(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: <Widget>[
          _buildProgress(),
          _buildSceneView(),
          const Gap(height: AppSpacing.lg),
          _buildCaption(),
          const Gap(height: AppSpacing.lg),
          AppText(
            text: '이 그림이 떠올리게 하는 노래는?',
            style: AppTypography.title3,
            color: AppColors.textStrong,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const Gap(height: AppSpacing.lg),
          _buildActions(context),
        ],
      ),
    );
  }

  /// 라운드 진행 바
  Widget _buildProgress() {
    return BlocBuilder<QuestionCubit, QuestionState>(
      buildWhen: (QuestionState previous, QuestionState current) =>
          previous.qIndex != current.qIndex,
      builder: (BuildContext context, QuestionState state) {
        return Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: QuestionProgress(
            totalSteps: questionList.length,
            currentStep: state.qIndex,
            fillColor: era.color,
          ),
        );
      },
    );
  }

  /// 클루 그림 — 문제가 바뀌거나 그림이 채워질 때만 다시 그린다
  Widget _buildSceneView() {
    return BlocBuilder<QuestionCubit, QuestionState>(
      buildWhen: (QuestionState previous, QuestionState current) =>
          previous.qIndex != current.qIndex ||
          previous.clueImagePathList != current.clueImagePathList,
      builder: (BuildContext context, QuestionState state) {
        return QuestionSceneView(
          sceneCount: questionList[state.qIndex].lyricLine.sceneCount,
          imagePathList: state.clueImagePathList,
          onSceneTapped: (int index) => _openSceneDetail(context, index),
        );
      },
    );
  }

  /// 장수 안내 칩
  Widget _buildCaption() {
    return BlocBuilder<QuestionCubit, QuestionState>(
      buildWhen: (QuestionState previous, QuestionState current) =>
          previous.qIndex != current.qIndex,
      builder: (BuildContext context, QuestionState state) {
        return _buildCaptionChip(
          questionList[state.qIndex].lyricLine.sceneCount,
        );
      },
    );
  }

  ///
  /// 그림들이 가사 한 줄이라는 규칙을 알리는 안내 칩
  ///
  Widget _buildCaptionChip(SceneCount sceneCount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.auto_awesome,
            size: 14,
            color: AppColors.textMuted,
          ),
          const Gap(width: AppSpacing.xs),
          AppText(
            text: _captionTextOf(sceneCount),
            style: AppTypography.caption,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  /// 힌트 보기 / 답안 공개
  Widget _buildActions(BuildContext context) {
    return QuestionActions(
      onHintTapped: () => HintBottomSheet.show(
        context,
        hints: viewModel(context).currentHints,
      ),
      onRevealTapped: () {
        if (!viewModel(context).revealAnswer()) return;
        _goToQuestionResult(context, isCorrect: false);
      },
    );
  }

  /// 하단 고정 입력 영역
  Widget _buildInputBar(
    BuildContext context, {
    required Listenable wrongAnswerSignal,
  }) {
    return QuestionInputBar(
      textController: viewModel(context).textController,
      wrongAnswerSignal: wrongAnswerSignal,
      onSubmit: (String guess) {
        if (!viewModel(context).submit(guess)) return;
        _goToQuestionResult(context, isCorrect: true);
      },
    );
  }

  // MARK: - Helpers

  ///
  /// 클루 그림 크게 보기 — 뒤 화면이 비치는 반투명 라우트로 띄운다(전환은 ImageDetailRoute)
  ///
  void _openSceneDetail(BuildContext context, int index) {
    final ImageDetailArgs detail = viewModel(context).sceneDetailOf(index);
    context.push(const ImageDetailRoute().location, extra: detail);
  }

  ///
  /// 문제 결과 화면으로 이동
  ///
  void _goToQuestionResult(BuildContext context, {required bool isCorrect}) {
    final QuestionCubit questionCubit = viewModel(context);
    context.push(
      const QuestionResultRoute().location,
      extra: (
        era: era,
        question: questionCubit.currentQuestion,
        imagePathList: questionCubit.state.clueImagePathList,
        onSceneTapped: (int index) => _openSceneDetail(context, index),
        isCorrect: isCorrect,
        isLast: questionCubit.isLastQuestion,
        onNext: () => _goToNext(context),
      ),
    );
  }

  ///
  /// 다음 단계 진행 — 마지막이면 라운드 결과, 아니면 다음 문제
  ///
  void _goToNext(BuildContext context) {
    final QuestionCubit questionCubit = viewModel(context);
    if (!questionCubit.isLastQuestion) {
      questionCubit.goToNextQuestion();
      context.pop();
      return;
    }
    context.pushReplacement(
      const RoundResultRoute().location,
      extra: (era: era, resultList: questionCubit.resultList),
    );
  }

  /// 장수에 맞는 안내 문구
  String _captionTextOf(SceneCount sceneCount) => switch (sceneCount) {
        SceneCount.one => '이 그림이 가사 한 줄을 나타냅니다',
        SceneCount.two => '두 그림이 가사 한 줄을 나타냅니다',
        SceneCount.three => '세 그림이 가사 한 줄을 나타냅니다',
      };
}
