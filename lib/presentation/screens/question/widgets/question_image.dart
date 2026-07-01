import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/image/cached_image.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';

/// 문제의 히어로 이미지(AI 그림).
///
/// [imageURL]이 비어 있으면 CachedImage가 대기(스켈레톤) 상태로 표시되고,
/// URL이 채워지면 로딩 후 이미지로 전환된다.
class QuestionImage extends StatelessWidget {
  /// 이미지 액자 높이
  static const double _height = 300;

  /// 생성된 그림 URL
  final String imageURL;

  const QuestionImage({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevationImage,
      ),
      child: CachedImage(
        imageURL: imageURL,
        width: double.infinity,
        height: _height,
        borderRadiusGeometry: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }
}
