import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/image_paths.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

/// 앱 메뉴 드롭다운
class AppMenuDropdown<T> extends StatefulWidget {
  final List<T> menuList;
  final Function(T menu) onMenuTapped;
  final String Function(T menu) labelBuilder;

  final Offset offset;
  final double borderRadius;
  final Color? borderColor;

  const AppMenuDropdown({
    super.key,
    required this.menuList,
    required this.onMenuTapped,
    required this.labelBuilder,
    this.offset = const Offset(-100, 30),
    this.borderRadius = 6,
    this.borderColor,
  });

  @override
  State<AppMenuDropdown<T>> createState() => _AppMenuDropdownState<T>();
}

class _AppMenuDropdownState<T> extends State<AppMenuDropdown<T>> {
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();

  ///
  /// 메뉴 너비 계산
  ///
  double _calculateMenuWidth(BuildContext context) {
    if (widget.menuList.isEmpty) {
      return 0;
    }

    final textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.48,
      fontFamily: AppFonts.pretendard,
    );

    // 텍스트 방향과 텍스트 스케일 팩터 가져오기
    final textDirection = Directionality.of(context);
    final textScaleFactor = MediaQuery.textScalerOf(context);

    // 최대 텍스트 너비 초기화
    double maxTextWidth = 0;

    // 메뉴 리스트 순회하며 최대 텍스트 너비 계산
    for (final menu in widget.menuList) {
      final label = widget.labelBuilder(menu);
      final painter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: textDirection,
        textScaler: textScaleFactor,
        maxLines: 1,
      )..layout();

      // 최대 텍스트 너비 업데이트
      if (painter.width > maxTextWidth) {
        maxTextWidth = painter.width;
      }
    }

    // 수평 패딩 계산
    const horizontalPadding = 15.0;

    // 메뉴 너비 계산
    final width = maxTextWidth + (horizontalPadding * 2);

    // 화면 너비 가져오기
    final screenWidth = MediaQuery.of(context).size.width;

    // 최대 너비 계산
    final maxWidth = screenWidth - 24;

    // 메뉴 너비 반환
    return width.clamp(0.0, maxWidth).toDouble();
  }

  /// 드롭다운 메뉴 표시
  void _show() {
    // 헌재 화면에서 Overlay 위젯 가져오기
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (details) {
          // 최소 움직임 임계값
          if (_entry != null && details.delta.dy.abs() > 4) {
            _hide();
          }
        },
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: widget.offset,
              child: buildOverlay(),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_entry!);
  }

  /// 드롭다운 메뉴 숨김
  void _hide() {
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
    }
    _entry = null;
  }

  /// 드롭다운 메뉴 렌더링
  Widget buildOverlay() {
    final menuWidth = _calculateMenuWidth(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: menuWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(107, 107, 107, 0.25),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.menuList.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.gray500,
            ),
            itemBuilder: (context, index) {
              final menu = widget.menuList[index];

              return InkWell(
                onTap: () {
                  widget.onMenuTapped(menu);
                  _hide();
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 15),
                  color: AppColors.black,
                  child: Center(
                    child: AppText(
                      text: widget.labelBuilder(menu),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_entry == null) {
            _show();
          } else {
            _hide();
          }
        },
        child: Image.asset(
          ImagePaths.arrowDown,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
