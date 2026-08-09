import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text_field/app_textfield.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/question/widgets/wrong_answer_note.dart';

/// 하단 고정 입력 영역 — 오답 안내 + 곡 제목 입력 + 제출. 키보드 위에 떠 있다.
class QuestionInputBar extends HookWidget {
  /// 텍스트 필드 컨트롤러
  final TextEditingController textController;

  /// 오답이 날 때마다 알림이 오는 신호. 값이 아니라 알림 자체가 의미다.
  final Listenable wrongAnswerSignal;

  /// 정답 제출 콜백
  final void Function(String guess) onSubmit;

  const QuestionInputBar({
    super.key,
    required this.textController,
    required this.wrongAnswerSignal,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // 입력값이 바뀌면 버튼 활성 상태를 다시 계산한다.
    useListenable(textController);
    final bool canSubmit = textController.text.trim().isNotEmpty;

    final ValueNotifier<bool> isWrongNoteVisible = useState<bool>(false);
    final ObjectRef<Timer?> wrongNoteTimer = useRef<Timer?>(null);

    void cancelWrongNoteTimer() {
      wrongNoteTimer.value?.cancel();
      wrongNoteTimer.value = null;
    }

    void hideWrongNote() {
      isWrongNoteVisible.value = false;
      wrongNoteTimer.value = null;
    }

    void showWrongNoteTemporarily() {
      isWrongNoteVisible.value = true;
      cancelWrongNoteTimer();
      wrongNoteTimer.value = Timer(const Duration(seconds: 2), hideWrongNote);
    }

    useEffect(() => cancelWrongNoteTimer, const <Object?>[]);

    // 신호는 오답이 날 때만 오므로 첫 렌더링에서 잘못 뜰 일이 없다.
    useEffect(() {
      wrongAnswerSignal.addListener(showWrongNoteTemporarily);
      return () => wrongAnswerSignal.removeListener(showWrongNoteTemporarily);
    }, <Object?>[wrongAnswerSignal]);

    void submitAnswer() {
      final String guess = textController.text.trim();
      if (guess.isEmpty) return;
      onSubmit(guess);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCanvas,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildWrongAnswerNote(
              isVisible: isWrongNoteVisible.value,
            ),
            _buildInputRow(
              canSubmit: canSubmit,
              onSubmitPressed: submitAnswer,
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 오답 안내를 부드럽게 표시하거나 숨긴다
  ///
  Widget _buildWrongAnswerNote({required bool isVisible}) {
    return AnimatedSwitcher(
      duration: AppMotion.durationBase,
      switchInCurve: AppMotion.emphasized,
      transitionBuilder: _buildWrongNoteTransition,
      child: isVisible ? const WrongAnswerNote() : const SizedBox.shrink(),
    );
  }

  ///
  /// 오답 안내가 아래에서 살짝 올라오며 페이드되는 전환 효과
  ///
  Widget _buildWrongNoteTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  ///
  /// 곡 제목 입력 필드와 제출 버튼을 한 줄로 배치한다
  ///
  Widget _buildInputRow({
    required bool canSubmit,
    required VoidCallback onSubmitPressed,
  }) {
    return Row(
      children: <Widget>[
        Expanded(child: _buildTextField(onSubmitPressed: onSubmitPressed)),
        const Gap(width: AppSpacing.sm),
        _buildSubmitButton(
          canSubmit: canSubmit,
          onSubmitPressed: onSubmitPressed,
        ),
      ],
    );
  }

  ///
  /// 사용자가 곡 제목을 입력하는 텍스트 필드
  ///
  Widget _buildTextField({required VoidCallback onSubmitPressed}) {
    return AppTextField(
      textController: textController,
      hintText: '곡 제목을 입력해요',
      radius: AppRadius.pill,
      fontSize: 15,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitPressed(),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
    );
  }

  ///
  /// 입력값이 있을 때만 활성화되는 제출 버튼
  ///
  Widget _buildSubmitButton({
    required bool canSubmit,
    required VoidCallback onSubmitPressed,
  }) {
    return AppButton(
      text: '제출',
      width: 80,
      height: 52,
      margin: 0,
      borderRadius: AppRadius.pill,
      disabled: !canSubmit,
      onTapped: onSubmitPressed,
    );
  }
}
