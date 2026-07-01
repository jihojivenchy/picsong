import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/sort/sort_option.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 정렬 조건 메뉴
class SortOptionDropdown extends StatefulWidget {
  final Offset offset;
  final double menuWidth;
  final Color? iconColor;

  final SortOption selectedSortOption;
  final Function(SortOption) onSortOptionChanged;

  const SortOptionDropdown({
    super.key,
    this.offset = const Offset(-70, 30),
    this.menuWidth = 120,
    this.iconColor,
    required this.selectedSortOption,
    required this.onSortOptionChanged,
  });

  @override
  State<SortOptionDropdown> createState() => _SortOptionDropdownState();
}

class _SortOptionDropdownState extends State<SortOptionDropdown>
    with SingleTickerProviderStateMixin {
  /// 화살표 애니메이션 처리
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  /// 드롭다운 메뉴 표시
  OverlayEntry? _entry;
  final LayerLink _layerLink = LayerLink();

  ///
  /// 초기화
  ///
  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (200ms 지속시간)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 0에서 0.5(180도)까지 회전하는 애니메이션
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 드롭다운 메뉴 표시
  void _show() {
    // 애니메이션 시작
    _animationController.forward();

    // 헌재 화면에서 Overlay 위젯 가져오기
    final overlay = Overlay.of(context);

    // 화면에 렌더링 할 위젯 반환
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
    // 애니메이션 종료
    _animationController.reverse();

    _entry?.remove();
    _entry = null;
  }

  /// 드롭다운 메뉴 렌더링
  Widget buildOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.menuWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(107, 107, 107, 0.25),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: SortOption.values.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1, color: AppColors.dividerLight),
          itemBuilder: (context, index) {
            final option = SortOption.values[index];
            final isSelected = widget.selectedSortOption == option;

            return InkWell(
              onTap: () {
                _hide();
                widget.onSortOptionChanged(option);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: 6,
                ),
                child: Center(
                  child: AppText(
                    text: option.displayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? AppColors.appColor
                        : AppColors.labelPrimary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
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
        child: Row(
          children: [
            AppText(
              text: widget.selectedSortOption.displayText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.labelSecondary,
            ),
            // 회전 애니메이션이 적용된 화살표
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.labelSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
