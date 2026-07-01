import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 조건부 섹션 등장 애니메이션 래퍼
///
/// [isVisible]이 false → true로 전환될 때 높이 확장 + 페이드인 애니메이션을
/// 재생하고, 가장 가까운 Scrollable로 자동 스크롤한다.
class AnimatedReveal extends HookWidget {
  /// 섹션 표시 여부
  final bool isVisible;

  /// 표시할 자식 위젯
  final Widget child;

  const AnimatedReveal({
    super.key,
    required this.isVisible,
    required this.child,
  });

  static const Duration _animationDuration = Duration(milliseconds: 400);
  static const Curve _animationCurve = Curves.easeOut;

  @override
  Widget build(BuildContext context) {
    // isVisible의 이전 값 추적 (false → true 전환 감지용)
    final previousIsVisible = useRef(isVisible);

    useEffect(() {
      final bool wasVisible = previousIsVisible.value;
      previousIsVisible.value = isVisible;

      // false → true 전환 시에만 자동 스크롤
      if (!wasVisible && isVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Scrollable.ensureVisible(
              context,
              duration: _animationDuration,
              curve: _animationCurve,
              alignment: 0.0,
            );
          }
        });
      }

      return null;
    }, [isVisible]);

    return AnimatedSize(
      duration: _animationDuration,
      curve: _animationCurve,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: _animationDuration,
        curve: _animationCurve,
        child: isVisible ? child : const SizedBox.shrink(),
      ),
    );
  }
}
