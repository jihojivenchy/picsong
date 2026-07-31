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

  /// ViewModel이 오답마다 증가시키는 신호. 같은 오답 반복도 감지하려고 int를 사용한다.
  final int wrongAnswerSignal;

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

    // 첫 렌더링 때 이전 오답 신호를 새 오답으로 오해하지 않도록 현재 값을 저장한다.
    final ObjectRef<int> handledWrongAnswerSignal =
        useRef<int>(wrongAnswerSignal);

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

    useEffect(() {
      if (wrongAnswerSignal == handledWrongAnswerSignal.value) return null;
      handledWrongAnswerSignal.value = wrongAnswerSignal;
      showWrongNoteTemporarily();
      return null;
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
