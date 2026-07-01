
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

/// 스켈레톤 박스
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 4,
  });

  final double width;
  final double height;
  final double borderRadius;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBase,
      highlightColor: AppColors.skeletonHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.skeletonBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
