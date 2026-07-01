import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/image_paths.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class AppExpansionMenuListView<T> extends HookWidget {
  const AppExpansionMenuListView({
    super.key,
    required this.menuList,
    required this.labelBuilder,
    required this.selectedMenu,
    required this.onMenuTapped,
    this.width,
    this.minTileHeight = 50,
  });

  final T selectedMenu;
  final List<T> menuList;
  final String Function(T) labelBuilder;
  final Function(T) onMenuTapped;

  final double? width;
  final double? minTileHeight;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    final controller = useMemoized(() => ExpansibleController());

    // 확장 여부에 따라 보더 컬러 다르게
    final borderColor =
        isExpanded.value ? AppColors.primary : AppColors.gray200;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpansionTile(
              minTileHeight: minTileHeight,
              controller: controller,
              tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              title: AppText(
                text: labelBuilder(selectedMenu),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray500,
              ),
              trailing: AnimatedRotation(
                turns: isExpanded.value ? 0.5 : 0, // 0.5 == 180도
                duration: const Duration(milliseconds: 200),
                child: Image.asset(ImagePaths.arrowDown, width: 24, height: 24),
              ),
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              backgroundColor: Colors.white,
              onExpansionChanged: (expanded) {
                isExpanded.value = expanded;
              },
              children: [
                Divider(color: AppColors.gray200, height: 1),
                _buildMenuList(
                  onMenuTapped: (menu) {
                    controller.collapse();
                    isExpanded.value = false;
                    onMenuTapped(menu);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 메뉴 리스트
  ///
  Widget _buildMenuList({required Function(T) onMenuTapped}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final menu = menuList[index];
        final isSelected = menu == selectedMenu;

        return InkWell(
          onTap: () {
            onMenuTapped(menu);
          },
          child: Container(
            width: double.infinity,
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 15),
            child: AppText(
              text: labelBuilder(menu),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray500,
            ),
          ),
        );
      },
    );
  }
}
