import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/image_detail/widgets/image_detail_indicator.dart';

/// 그림을 크게 보는 뷰어 — 핀치로 확대, 좌우로 컷 넘기기, 위아래로 끌어 닫기.
class ImageDetailViewer extends HookWidget {
  /// 이만큼 끌면 화면을 닫는다
  static const double _dismissDistance = 100;

  /// 배경이 가장 옅어지는 드래그 거리
  static const double _fadeDistance = 300;

  /// 끝까지 끌어도 남겨두는 배경 어둡기
  static const double _minBackgroundOpacity = 0.3;

  /// 크게 볼 이미지 경로 목록 — 로컬 파일 경로 또는 원격 URL
  final List<String> imagePathList;

  /// 처음 보여줄 이미지 위치
  final int initialIndex;

  const ImageDetailViewer({
    super.key,
    required this.imagePathList,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final PageController pageController =
        usePageController(initialPage: initialIndex);
    final ValueNotifier<int> currentIndex = useState<int>(initialIndex);
    // 드래그 값은 매 프레임 바뀐다. 구독하면 갤러리까지 다시 만들어져 손가락을 못 따라온다
    final ValueNotifier<double> dragOffset = useValueNotifier<double>(0);
    final ObjectRef<bool> isDragging = useRef<bool>(false);
    final ObjectRef<bool> isZoomed = useRef<bool>(false);
    final PhotoViewScaleStateController scaleController =
        _useScaleController(isZoomed);

    // 확대 상태에서는 그림을 옮겨 보는 중이므로 닫기 드래그로 해석하지 않는다.
    void startDrag() => isDragging.value = !isZoomed.value;

    void updateDrag(DragUpdateDetails details) {
      if (!isDragging.value) return;
      dragOffset.value += details.delta.dy;
    }

    void endDrag() {
      if (!isDragging.value) return;
      // 닫히는 중에는 제자리로 되돌리는 애니메이션을 시작하지 않는다
      if (dragOffset.value.abs() > _dismissDistance) {
        context.pop();
        return;
      }
      isDragging.value = false;
      dragOffset.value = 0;
    }

    return GestureDetector(
      onVerticalDragStart: (DragStartDetails details) => startDrag(),
      onVerticalDragUpdate: updateDrag,
      onVerticalDragEnd: (DragEndDetails details) => endDrag(),
      child: _buildFadingBackground(
        dragOffset: dragOffset,
        isDragging: isDragging,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildDraggableGallery(
              pageController: pageController,
              scaleController: scaleController,
              onPageChanged: (int index) => currentIndex.value = index,
              dragOffset: dragOffset,
              isDragging: isDragging,
            ),
            _buildCloseButton(context),
            if (imagePathList.length > 1) _buildIndicator(currentIndex.value),
          ],
        ),
      ),
    );
  }

  ///
  /// 확대 여부를 [isZoomed]에 반영하는 스케일 컨트롤러를 만든다
  ///
  PhotoViewScaleStateController _useScaleController(ObjectRef<bool> isZoomed) {
    final PhotoViewScaleStateController controller =
        useMemoized(PhotoViewScaleStateController.new);
    useEffect(() {
      final StreamSubscription<PhotoViewScaleState> subscription =
          controller.outputScaleStateStream.listen(
        (PhotoViewScaleState state) => isZoomed.value = _isZoomedState(state),
      );
      return () {
        subscription.cancel();
        controller.dispose();
      };
    }, <Object>[controller]);
    return controller;
  }

  ///
  /// 끈 거리만큼 옅어지는 배경 — [child]는 다시 만들지 않는다
  ///
  Widget _buildFadingBackground({
    required ValueNotifier<double> dragOffset,
    required ObjectRef<bool> isDragging,
    required Widget child,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: dragOffset,
      child: child,
      builder: (BuildContext context, double offset, Widget? content) =>
          AnimatedContainer(
        duration: _settleDuration(isDragging.value),
        curve: AppMotion.standard,
        color: AppColors.black.withValues(alpha: _backgroundOpacity(offset)),
        child: content,
      ),
    );
  }

  ///
  /// 드래그를 따라 움직이는 갤러리 — 손을 떼면 제자리로 되돌아간다
  ///
  Widget _buildDraggableGallery({
    required PageController pageController,
    required PhotoViewScaleStateController scaleController,
    required void Function(int index) onPageChanged,
    required ValueNotifier<double> dragOffset,
    required ObjectRef<bool> isDragging,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: dragOffset,
      child: _buildGallery(
        pageController: pageController,
        scaleController: scaleController,
        onPageChanged: onPageChanged,
      ),
      builder: (BuildContext context, double offset, Widget? gallery) =>
          AnimatedContainer(
        duration: _settleDuration(isDragging.value),
        curve: AppMotion.standard,
        transform: Matrix4.translationValues(0, offset, 0),
        child: gallery,
      ),
    );
  }

  ///
  /// 좌우로 넘겨보는 갤러리
  ///
  Widget _buildGallery({
    required PageController pageController,
    required PhotoViewScaleStateController scaleController,
    required void Function(int index) onPageChanged,
  }) {
    return PhotoViewGallery.builder(
      pageController: pageController,
      itemCount: imagePathList.length,
      onPageChanged: onPageChanged,
      backgroundDecoration: const BoxDecoration(color: AppColors.transparent),
      builder: (BuildContext context, int index) => PhotoViewGalleryPageOptions(
        imageProvider: _resolveImageProvider(imagePathList[index]),
        scaleStateController: scaleController,
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 3,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) =>
            _buildBrokenImage(),
      ),
    );
  }

  ///
  /// 좌상단 닫기 버튼
  ///
  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: AppColors.white, size: 28),
        ),
      ),
    );
  }

  ///
  /// 지금 몇 번째 그림인지 알려주는 하단 배지
  ///
  Widget _buildIndicator(int currentIndex) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: AppSpacing.xxxl,
      child: Center(
        child: ImageDetailIndicator(
          currentIndex: currentIndex,
          totalCount: imagePathList.length,
        ),
      ),
    );
  }

  ///
  /// 그림을 읽지 못했을 때의 자리 표시
  ///
  Widget _buildBrokenImage() {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: AppColors.textMuted,
        size: 48,
      ),
    );
  }

  ///
  /// 온디바이스 생성물은 파일에서, 원격 그림은 캐시에서 읽는다
  ///
  ImageProvider _resolveImageProvider(String imagePath) =>
      imagePath.startsWith('/')
          ? FileImage(File(imagePath))
          : CachedNetworkImageProvider(imagePath);

  ///
  /// 끄는 중에는 손가락을 그대로 따라가고, 놓으면 부드럽게 제자리로 간다
  ///
  Duration _settleDuration(bool isDragging) =>
      isDragging ? Duration.zero : AppMotion.durationBase;

  ///
  /// 끈 거리만큼 배경을 옅게 만든다
  ///
  double _backgroundOpacity(double dragOffset) =>
      (1 - dragOffset.abs() / _fadeDistance).clamp(_minBackgroundOpacity, 1);

  ///
  /// 기본 크기보다 크게 확대된 상태인지 판단한다
  ///
  bool _isZoomedState(PhotoViewScaleState state) =>
      state != PhotoViewScaleState.initial &&
      state != PhotoViewScaleState.zoomedOut;
}
