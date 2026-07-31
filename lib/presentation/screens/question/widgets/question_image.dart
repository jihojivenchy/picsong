import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/image/cached_image.dart';
import 'package:picsong/presentation/design_system/components/skeleton/skeleton_box.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';

/// 문제의 히어로 이미지(AI 그림).
///
/// [imageURL]이 비어 있으면 대기(스켈레톤) 상태로 표시된다.
/// 온디바이스로 생성된 이미지는 로컬 파일 경로로, 원격 이미지는 URL로 들어온다.
class QuestionImage extends StatelessWidget {
  /// 이미지 액자 높이
  static const double _height = 300;

  /// 생성된 그림 경로 — 로컬 파일 경로 또는 원격 URL
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
      child: imageURL.startsWith('/') ? _buildLocalImage() : _buildRemoteImage(),
    );
  }

  ///
  /// 온디바이스 생성물(로컬 파일)을 표시
  ///
  Widget _buildLocalImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Image.file(
        File(imageURL),
        width: double.infinity,
        height: _height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => SkeletonBox(
          width: double.infinity,
          height: _height,
          borderRadius: AppRadius.xl,
        ),
      ),
    );
  }

  ///
  /// 원격 URL 이미지를 표시
  ///
  Widget _buildRemoteImage() {
    return CachedImage(
      imageURL: imageURL,
      width: double.infinity,
      height: _height,
      borderRadiusGeometry: BorderRadius.circular(AppRadius.xl),
    );
  }
}
