import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 제네릭 필터 선택 바텀시트
class FilterBottomSheet<T> extends HookWidget {
  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.values,
    required this.initialFilter,
    required this.labelBuilder,
    required this.onFilterSelected,
  });

  final String title;
  final List<T> values;
  final T initialFilter;
  final String Function(T) labelBuilder;
  final Function(T) onFilterSelected;

  /// 바텀 시트 표시
  static void show<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T initialFilter,
    required String Function(T) labelBuilder,
    required Function(T) onFilterSelected,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet<T>(
          title: title,
          values: values,
          initialFilter: initialFilter,
          labelBuilder: labelBuilder,
          onFilterSelected: onFilterSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 임시 선택 상태
    final tempSelectedFilter = useState<T>(initialFilter);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheet),
          topRight: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildFilterOptions(tempSelectedFilter),
          _buildSubmitButton(tempSelectedFilter.value),
        ],
      ),
    );
  }

  // 타이틀 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Center(
        child: AppText(
          text: title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.gray900,
        ),
      ),
    );
  }

  // 필터 옵션 리스트
  Widget _buildFilterOptions(ValueNotifier<T> selectedFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
      child: Column(
        children: values.map((filter) {
          final bool isSelected = selectedFilter.value == filter;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => selectedFilter.value = filter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 필터 텍스트
                  AppText(
                    text: labelBuilder(filter),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  // 라디오 버튼
                  _buildRadioIndicator(isSelected),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 라디오 인디케이터
  Widget _buildRadioIndicator(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.primary500,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.figmaGray200, width: 1),
      ),
    );
  }

  // 선택 완료 버튼
  Widget _buildSubmitButton(T selectedFilter) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.gray100),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: AppButton(
              text: '선택',
              margin: 0,
              height: 48,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primary500,
              onTapped: () {
                onFilterSelected(selectedFilter);
                Get.back();
              },
            ),
          ),
        ),
      ],
    );
  }
}
