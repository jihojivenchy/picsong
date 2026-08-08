import 'package:flutter/material.dart';
import 'package:picsong/presentation/common/base/legacy_base_screen.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/screens/image_detail/widgets/image_detail_viewer.dart';

/// 그림을 전체 화면으로 크게 보는 상세 화면.
///
/// 뒤 화면이 비쳐야 하므로 `opaque: false` 라우트로 띄운다.
class ImageDetailScreen extends LegacyBaseScreen {
  /// 크게 볼 이미지 경로 목록 — 로컬 파일 경로 또는 원격 URL
  final List<String> imagePathList;

  /// 처음 보여줄 이미지 위치
  final int initialIndex;

  const ImageDetailScreen({
    super.key,
    required this.imagePathList,
    required this.initialIndex,
  });

  /// 배경 어둡기를 본문이 직접 그리므로 화면 배경은 비워둔다
  @override
  Color backgroundColor(BuildContext context) => AppColors.transparent;

  /// 그림이 화면 끝까지 차도록 SafeArea를 두지 않는다
  @override
  bool get wrapWithSafeArea => false;

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return ImageDetailViewer(
      imagePathList: imagePathList,
      initialIndex: initialIndex,
    );
  }
}
