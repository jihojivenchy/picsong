
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/image_paths.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

///
/// 체크 버튼
///
class AppCheckButton extends StatelessWidget {
  const AppCheckButton({
    super.key,
    this.text,
    required this.isSelected,
    required this.onTapped,
    this.onArrowTapped,
  });

  final String? text;
  final bool isSelected;
  final Function(bool) onTapped;
  final VoidCallback? onArrowTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTapped(!isSelected),
      child: Row(
        children: [
          if (text != null) ...[
            const Gap(width: AppSpacing.sm),
            AppText(
              text: text!,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ],
          const Spacer(),
          if (onArrowTapped != null) ...[
            const Gap(width: AppSpacing.md),
            GestureDetector(
              onTap: onArrowTapped,
              child: Image.asset(
                ImagePaths.arrowRight,
                width: 12,
                height: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
