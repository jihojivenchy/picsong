
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 제네릭한 리스트를 표시하는 바텀 시트
class MenuListBottomSheet<T> extends StatelessWidget {
  const MenuListBottomSheet({
    super.key,
    required this.menuList,
    required this.labelBuilder,
    required this.onMenuTapped,
  });

  final List<T> menuList;
  final String Function(T) labelBuilder;
  final Function(T) onMenuTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(height: 10),
            Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.gray30,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Gap(height: 40),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                final menu = menuList[index];
        
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onMenuTapped.call(menu);
                  },
                  child: Center(
                    child: AppText(
                      text: labelBuilder(menu),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Gap(height: AppSpacing.xl),
            ),
            const Gap(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
