import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

/// 리스트 아이템 trailing용 라디오 인디케이터 (선택 시 primary 배경 + 흰색 내부 점)
class RadioIndicator extends StatelessWidget {
  const RadioIndicator({super.key, required this.isSelected});

  /// 선택 여부
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.primary500,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.figmaGray200, width: 1),
      ),
    );
  }
}
