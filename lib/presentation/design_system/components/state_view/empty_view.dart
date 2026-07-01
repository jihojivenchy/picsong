import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.question_mark_outlined,
            size: 64,
            color: AppColors.labelTertiary,
          ),
          const Gap(height: AppSpacing.lg),
          AppText(
            text: title,
            fontSize: 16,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w500,
            color: AppColors.labelTertiary,
          ),
        ],
      ),
    );
  }
}
