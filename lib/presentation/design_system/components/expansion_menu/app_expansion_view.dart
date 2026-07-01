import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/image_paths.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class AppExpansionView extends HookWidget {
  const AppExpansionView({
    super.key,
    required this.title,
    required this.content,
    this.isShowTopBorder = true,
  });

  final String title;
  final Widget content;
  final bool isShowTopBorder;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    final controller = useMemoized(() => ExpansibleController());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: isShowTopBorder
              ? BorderSide(color: AppColors.gray200, width: 1)
              : BorderSide.none,
          bottom: BorderSide(
            color: isExpanded.value ? AppColors.white : AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpansionTile(
              minTileHeight: 56,
              controller: controller,
              tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              title: AppText(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
              trailing: AnimatedRotation(
                turns: isExpanded.value ? 0.5 : 0, // 0.5 == 180도
                duration: const Duration(milliseconds: 200),
                child: Image.asset(ImagePaths.arrowDown, width: 20, height: 20),
              ),
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              backgroundColor: Colors.white,
              onExpansionChanged: (expanded) {
                isExpanded.value = expanded;
              },
              children: [
                Divider(color: AppColors.gray200, height: 1),
                content,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
