import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';


/// 탭 바 델리게이트
class AppTabBarDelegate extends SliverPersistentHeaderDelegate {
  const AppTabBarDelegate({required this.tabBar, this.height = 48.0});

  final Widget tabBar;
  final double height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant AppTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
