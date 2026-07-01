import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class AppProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double spacing;
  final double barHeight;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const AppProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.spacing = 7,
    this.barHeight = 6,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.colorE5,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSteps <= 0) return const SizedBox.shrink();

    final int normalizedCurrentStep = currentStep.clamp(0, totalSteps - 1);
    final double targetProgress = (normalizedCurrentStep + 1) / totalSteps;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetProgress),
      duration: animationDuration,
      curve: animationCurve,
      builder: (context, animatedProgress, _) {
        final double animatedStepValue = animatedProgress * totalSteps;

        return SizedBox(
          height: barHeight,
          child: Row(
            children: List.generate(totalSteps, (index) {
              final bool isLast = index == totalSteps - 1;

              // 1. 해당 인덱스의 채워짐 정도 계산 (0.0 ~ 1.0)
              final double fillAmount =
                  (animatedStepValue - index).clamp(0.0, 1.0);

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : spacing),
                  decoration: BoxDecoration(
                    color: inactiveColor,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: fillAmount, // 0.0에서 1.0으로 자연스럽게 변화
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: fillAmount,
                              heightFactor: 1.0,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: activeColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
