import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';


class AutoHideBarController {
  final Animation<Offset> offsetAnimation;
  final bool Function(ScrollNotification) onNotification;
  final AnimationController animationController; 

  const AutoHideBarController({
    required this.offsetAnimation,
    required this.onNotification,
    required this.animationController,
  });
}

/// 상단 Bar를 스크롤 방향에 따라 hide/show 하는 공용 Hook 로직
AutoHideBarController useAutoHideBar({
  Duration duration = const Duration(milliseconds: 300),
  double hideOffset = 30, // 앱바 숨기기 위한 최소 스크롤 위치
}) {
  // 애니메이션 컨트롤러 설정
  final animationController = useAnimationController(
    duration: duration,
    initialValue: 1.0, // 처음에는 보이게
  );

  // 애니메이션 설정
  final offset = useMemoized(
    () => Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    ),
    [animationController],
  );

  final isBarVisible = useRef(true);
  final lastOffset = useRef(0.0);

  bool handleScroll(ScrollNotification notification) {
    // 수직 스크롤 이벤트만 처리. 가로 스크롤은 무시.
    if (notification.metrics.axis != Axis.vertical) return false;

    // 스크롤 시작 시점에 현재 위치를 저장
    if (notification is ScrollStartNotification) {
      lastOffset.value = notification.metrics.pixels;

      // 스크롤 업데이트 이벤트 발생 시,
    } else if (notification is ScrollUpdateNotification) {
      // 현재 스크롤 위치
      final currentOffset = notification.metrics.pixels;

      // 이번 이벤트에서의 스크롤 변화량 (양수: 아래로 스크롤, 음수: 위로 스크롤)
      final delta = notification.scrollDelta ?? 0;

      // 스크롤 위치가 hideOffset 이하일 경우, 앱바 보이게 (최상단)
      if (currentOffset < hideOffset) {
        // 앱바가 숨겨져 있고, 애니메이션이 진행중이 아니면 앱바 보이기
        if (!isBarVisible.value && !animationController.isAnimating) {
          animationController.forward();
          isBarVisible.value = true;
        }
        lastOffset.value = currentOffset;
        return false;
      }

      // 아래로 스크롤 할 경우 -> 앱바 숨기기
      if (isBarVisible.value && delta > 5 && !animationController.isAnimating) {
        animationController.reverse();
        isBarVisible.value = false;

        // 위로 스크롤 할 경우 -> 앱바 보이기
      } else if (!isBarVisible.value &&
          delta < -5 &&
          !animationController.isAnimating) {
        animationController.forward();
        isBarVisible.value = true;
      }

      // 마지막 위치 갱신
      lastOffset.value = currentOffset;
    }

    return false;
  }

  return AutoHideBarController(
    offsetAnimation: offset,
    onNotification: handleScroll,
    animationController: animationController,
  );
}
