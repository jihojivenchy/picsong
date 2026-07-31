import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

/// 온보딩 스텝 공통 레이아웃 — 본문 + 하단 액션
class OnboardingStepLayout extends StatelessWidget {
  /// 스텝 본문
  final Widget body;

  /// 하단 액션 영역 (버튼이 여러 개면 호출부에서 Column으로 묶는다)
  final Widget foot;

  const OnboardingStepLayout({
    super.key,
    required this.body,
    required this.foot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: body,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          ),
          child: foot,
        ),
      ],
    );
  }
}
