import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 버튼 그룹 옵션
class AppButtonOption<T> {
  final T value;
  final String text;

  const AppButtonOption({
    required this.value,
    required this.text,
  });
}

/// 옵션 중 선택하는 버튼 그룹
/// T: 선택할 값의 타입 (예: enum, String, int 등)
class AppButtonGroup<T> extends StatefulWidget {
  /// 버튼 옵션들의 리스트
  final List<AppButtonOption<T>> options;

  /// 현재 선택된 값
  final T? selectedValue;

  final double? buttonHeight;

  /// 값이 변경될 때 호출되는 콜백
  final ValueChanged<T>? onChanged;

  /// 버튼 그룹의 배경색
  final Color backgroundColor;

  /// 선택된 버튼의 배경색
  final Color selectedBackgroundColor;

  /// 선택된 버튼의 보더 색상
  final Color selectedBorderColor;

  /// 선택된 버튼의 텍스트 색상
  final Color selectedTextColor;

  /// 선택되지 않은 버튼의 텍스트 색상
  final Color unselectedTextColor;

  const AppButtonGroup({
    super.key,
    required this.options,
    this.buttonHeight = 56,
    this.selectedValue,
    this.onChanged,
    this.backgroundColor = AppColors.backgroundSoftGray,
    this.selectedBackgroundColor = AppColors.white,
    this.selectedBorderColor = AppColors.accentTeal,
    this.selectedTextColor = AppColors.accentTeal,
    this.unselectedTextColor = AppColors.gray696E78,
  });

  @override
  State<AppButtonGroup<T>> createState() => _AppButtonGroupState<T>();
}

class _AppButtonGroupState<T> extends State<AppButtonGroup<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 슬라이드 애니메이션 설정
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 초기 선택된 인덱스 설정
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(AppButtonGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 선택된 값이 변경되었을 때 인덱스 업데이트
    if (oldWidget.selectedValue != widget.selectedValue) {
      _updateSelectedIndex();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 선택된 값에 따른 인덱스 업데이트
  void _updateSelectedIndex() {
    final newIndex = widget.selectedValue != null
        ? widget.options.indexWhere(
            (option) => option.value == widget.selectedValue,
          )
        : 0;

    if (newIndex != -1 && newIndex != _selectedIndex) {
      final oldIndex = _selectedIndex;

      setState(() {
        _selectedIndex = newIndex;
      });

      // 슬라이딩 애니메이션 설정 및 실행
      _slideAnimation = Tween<Offset>(
        begin: Offset(oldIndex?.toDouble() ?? 0, 0),
        end: Offset(newIndex.toDouble(), 0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.forward(from: 0.0);
    }
  }


  /// 버튼 탭 핸들러
  void _handleButtonTap(int index) {
    final option = widget.options[index];
    widget.onChanged?.call(option.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.buttonHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _buildSlidingBackground(constraints),
              Row(
                children: widget.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = index == _selectedIndex;

                  return Expanded(
                    child: _buildButton(
                      text: option.text,
                      isSelected: isSelected,
                      onTap: () => _handleButtonTap(index),
                      selectedTextColor: widget.selectedTextColor,
                      unselectedTextColor: widget.unselectedTextColor,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 슬라이딩하는 선택된 배경 위젯
  Widget _buildSlidingBackground(BoxConstraints constraints) {
    // 버튼 너비 계산
    final buttonWidth = constraints.maxWidth / widget.options.length;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        // 슬라이드 오프셋 계산
        final slideOffset = _slideAnimation.value.dx * buttonWidth;

        return Positioned(
          left: slideOffset,
          top: 0,
          bottom: 0,
          child: Container(
            width: buttonWidth,
            decoration: BoxDecoration(
              color: widget.selectedBackgroundColor,
              border: Border.all(
                color: widget.selectedBorderColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        );
      },
    );
  }

  /// 버튼
  Widget _buildButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedTextColor,
    required Color unselectedTextColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? selectedTextColor : unselectedTextColor,
            letterSpacing: -0.4, // -2% of 20px
            height: 1.4,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
