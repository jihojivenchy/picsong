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
  /// 제출 버튼 높이
  static const double _submitHeight = 52;

  /// 제출 버튼 너비
  static const double _submitWidth = 80;

  /// 오답 안내 배너 표시 시간
  static const Duration _noteVisibleDuration = Duration(milliseconds: 1400);

  /// 정답 제출 콜백 — 정답이면 true, 오답이면 false 반환
  final bool Function(String guess) onSubmit;

  const QuestionInputBar({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = useTextEditingController();
    useListenable(textController);
    final bool canSubmit = textController.text.trim().isNotEmpty;
    final ValueNotifier<bool> wrongVisible = useState<bool>(false);
    final ObjectRef<Timer?> wrongTimer = useRef<Timer?>(null);
    useEffect(() => () => wrongTimer.value?.cancel(), const <Object?>[]);

    void showWrongNote() {
      wrongVisible.value = true;
      wrongTimer.value?.cancel();
      wrongTimer.value = Timer(
        _noteVisibleDuration,
        () => wrongVisible.value = false,
      );
    }

    void handleSubmit() {
      final String guess = textController.text.trim();
      if (guess.isEmpty) return;
      final bool isCorrect = onSubmit(guess);
      if (isCorrect) return;
      showWrongNote();
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
            AnimatedSwitcher(
              duration: AppMotion.durationBase,
              switchInCurve: AppMotion.emphasized,
              transitionBuilder: (Widget child, Animation<double> animation) {
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
              },
              child: wrongVisible.value
                  ? const WrongAnswerNote()
                  : const SizedBox.shrink(),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    textController: textController,
                    hintText: '곡 제목을 입력해요',
                    radius: AppRadius.pill,
                    fontSize: 15,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => handleSubmit(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
                const Gap(width: AppSpacing.sm),
                AppButton(
                  text: '제출',
                  width: _submitWidth,
                  height: _submitHeight,
                  margin: 0,
                  borderRadius: AppRadius.pill,
                  disabled: !canSubmit,
                  onTapped: handleSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
