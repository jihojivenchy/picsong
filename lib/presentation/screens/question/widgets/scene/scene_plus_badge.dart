import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

/// 그림들이 더해져 가사 한 줄이 된다는 것을 암시하는 장식 배지.
class ScenePlusBadge extends StatelessWidget {
  /// 배지 지름
  static const double _size = 26;

  const ScenePlusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: const Icon(
        Icons.add,
        size: 14,
        color: AppColors.textMuted,
      ),
    );
  }
}
