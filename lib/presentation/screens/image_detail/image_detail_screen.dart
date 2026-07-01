import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/domain/entities/image/app_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// 이미지 상세 화면
class ImageDetailScreen extends HookWidget {
  const ImageDetailScreen({
    super.key,
    required this.imageList,
    required this.initialIndex,
  });

  final List<AppImage> imageList;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    // 화면 크기
    final Size screenSize = MediaQuery.of(context).size;

    // 페이지 컨트롤러
    final pageController = usePageController(initialPage: initialIndex);

    // snap-back 애니메이션 컨트롤러
    final snapBackController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    // 현재 페이지 인덱스
    final currentIndex = useState<int>(initialIndex);

    // 드래그 오프셋 (세로 드래그 dismiss용)
    final dragOffset = useState<double>(0);

    // 배경 불투명도
    final opacity = useState<double>(1.0);

    // 줌 상태 여부
    final isZoomed = useState<bool>(false);

    // PhotoView 스케일 상태 컨트롤러 (줌 감지용)
    final scaleStateController = useMemoized(
      () => PhotoViewScaleStateController(),
    );

    // 스케일 상태 스트림 구독 → 줌 여부 업데이트
    useEffect(() {
      final subscription = scaleStateController.outputScaleStateStream.listen(
        (scaleState) {
          isZoomed.value = scaleState != PhotoViewScaleState.initial &&
              scaleState != PhotoViewScaleState.zoomedOut;
        },
      );
      return () {
        subscription.cancel();
        scaleStateController.dispose();
      };
    }, [scaleStateController]);

    /// 드래그 dismiss 업데이트
    void onVerticalDragUpdate(DragUpdateDetails details) {
      if (isZoomed.value) return;
      dragOffset.value += details.delta.dy;
      opacity.value = (1 - dragOffset.value.abs() / 300).clamp(0.3, 1.0);
    }

    /// snap-back 애니메이션 실행
    void animateSnapBack() {
      final double startOffset = dragOffset.value;
      final double startOpacity = opacity.value;

      snapBackController.reset();

      final Animation<double> animation = CurvedAnimation(
        parent: snapBackController,
        curve: Curves.easeOut,
      );

      void listener() {
        dragOffset.value = startOffset * (1 - animation.value);
        opacity.value = startOpacity + (1.0 - startOpacity) * animation.value;
      }

      animation.addListener(listener);
      snapBackController.forward().then((_) {
        animation.removeListener(listener);
      });
    }

    /// 드래그 종료 시 dismiss 또는 snap-back
    void onVerticalDragEnd(DragEndDetails details) {
      if (isZoomed.value) return;
      if (dragOffset.value.abs() > 100) {
        Get.back();
        return;
      }
      animateSnapBack();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: onVerticalDragUpdate,
        onVerticalDragEnd: onVerticalDragEnd,
        child: Container(
          color: AppColors.black.withValues(alpha: opacity.value),
          child: Stack(
            children: [
              // 이미지 갤러리
              Transform.translate(
                offset: Offset(0, dragOffset.value),
                child: PhotoViewGallery.builder(
                  pageController: pageController,
                  itemCount: imageList.length,
                  onPageChanged: (index) => currentIndex.value = index,
                  builder: (context, index) {
                    final AppImage image = imageList[index];
                    final imageScale = _calculateInitialScale(
                      image,
                      screenSize,
                    );
                    return PhotoViewGalleryPageOptions(
                      imageProvider: CachedNetworkImageProvider(image.imageURL),
                      initialScale: imageScale,
                      maxScale: PhotoViewComputedScale.covered * 3,
                      minScale: imageScale,
                      scaleStateController: scaleStateController,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.gray500,
                            size: 48,
                          ),
                        );
                      },
                    );
                  },
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // 닫기 버튼
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              // 페이지 인디케이터 (이미지 2장 이상일 때만 표시)
              if (imageList.length > 1)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        text: '${currentIndex.value + 1}/${imageList.length}',
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 모든 이미지가 동일한 높이로 표시되도록 스케일 계산 (사이즈 미지정 시 contained)
  dynamic _calculateInitialScale(AppImage image, Size screenSize) {
    if (image.width == 0 || image.height == 0) {
      return PhotoViewComputedScale.contained;
    }
    final int imgW = image.width;
    final int imgH = image.height;
    final double targetHeight = screenSize.height * 0.65;
    final double scaleForHeight = targetHeight / imgH;
    final double widthAtScale = imgW * scaleForHeight;
    if (widthAtScale > screenSize.width) {
      return screenSize.width / imgW;
    }
    return scaleForHeight;
  }
}
