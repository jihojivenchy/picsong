import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:picsong/presentation/common/extensions/num_extension.dart';
import 'package:picsong/presentation/design_system/components/image/cached_image.dart';
import 'package:picsong/presentation/design_system/components/skeleton/skeleton_box.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 삭제 가능한 이미지 아이템
class DeleteableImageItem extends StatelessWidget {
  const DeleteableImageItem({
    super.key,
    this.image,
    required this.onDeleteTapped,
    this.imageURL,
  });

  final File? image;
  final String? imageURL;
  final VoidCallback onDeleteTapped;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Stack(
        children: [
          if (imageURL == null && image != null) ...[
            /// 선택된 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.file(
                image!,
                height: 100,
                width: 100,
                cacheWidth: 100.cacheSize(context),
                cacheHeight: 100.cacheSize(context),
                fit: BoxFit.cover,
              ),
            ),
          ] else ...[
            /// 업로드된 이미지
            CachedImage(
              imageURL: imageURL!,
              width: 100,
              height: 100,
              placeholderWidget: SkeletonBox(
                width: 100,
                height: 100,
              ),
            ),
          ],
          Positioned(
            right: -2,
            top: -2,
            child: GestureDetector(
              onTap: onDeleteTapped,
              child: Image.asset(
                '',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
