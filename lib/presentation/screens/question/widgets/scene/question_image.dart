import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/image/cached_image.dart';
import 'package:picsong/presentation/design_system/components/skeleton/skeleton_box.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 문제의 클루 이미지(AI 그림) 한 칸.
///
/// [imageURL]이 비어 있으면 대기(스켈레톤) 상태로 표시된다.
/// 크기는 부모가 정한다 — 액자가 내어준 칸을 그대로 채운다.
/// 온디바이스로 생성된 이미지는 로컬 파일 경로로, 원격 이미지는 URL로 들어온다.
class QuestionImage extends StatelessWidget {
  /// 생성된 그림 경로 — 로컬 파일 경로 또는 원격 URL
  final String imageURL;

  /// 모서리 둥글기 — 한 장짜리 문제는 더 크게 쓴다
  final double borderRadius;

  const QuestionImage({
    super.key,
    required this.imageURL,
    this.borderRadius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _buildContent(),
    );
  }

  ///
  /// 경로 상태에 따라 대기·로컬·원격 표시를 고른다
  ///
  Widget _buildContent() {
    if (imageURL.isEmpty) return _buildPending();
    if (imageURL.startsWith('/')) return _buildLocalImage();
    return _buildRemoteImage();
  }

  ///
  /// 아직 그리는 중인 자리를 대기로 표시
  ///
  Widget _buildPending() => SkeletonBox(borderRadius: borderRadius);

  ///
  /// 온디바이스 생성물(로컬 파일)을 표시
  ///
  Widget _buildLocalImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(imageURL),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPending(),
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
      height: double.infinity,
      borderRadiusGeometry: BorderRadius.circular(borderRadius),
    );
  }
}
