import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

enum SelectableOptionWrapViewType {
  single,
  multi,
}

class SelectableOptionWrapView<T> extends StatelessWidget {
  const SelectableOptionWrapView({
    super.key,
    this.type = SelectableOptionWrapViewType.single,
    required this.title,
    required this.selectedOptionList,
    required this.optionList,
    required this.labelBuilder,
    required this.onOptionTapped,
    this.isRequired = false,
    this.errorText,
  });

  final SelectableOptionWrapViewType type;
  final String title;

  final List<T> selectedOptionList;
  final List<T> optionList;
  final String Function(T) labelBuilder;
  final Function(T) onOptionTapped;

  /// 필수 입력 표시 여부
  final bool isRequired;

  /// 에러 메시지 (non-null이면 하단에 빨간 텍스트 표시)
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀 + 필수 표시
        Row(
          children: [
            AppText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            if (isRequired)
              AppText(
                text: ' *',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentCoral,
              ),
          ],
        ),
        const Gap(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: optionList.map((T option) {
            // 단일 선택 시 -> 해당 옵션이 선택되었는지 확인
            // 다중 선택 시 -> 해당 옵션이 선택된 리스트에 포함되어 있는지 확인
            final isSelected = switch (type) {
              SelectableOptionWrapViewType.single =>
                selectedOptionList.firstOrNull == option,
              SelectableOptionWrapViewType.multi =>
                selectedOptionList.contains(option),
            };

            return _buildOption(
              option: option,
              isSelected: isSelected,
              onTapped: () => onOptionTapped(option),
            );
          }).toList(),
        ),
        // 에러 메시지 표시
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: AppText(
              text: errorText!,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accentCoral,
            ),
          ),
      ],
    );
  }

  ///
  /// 빌드 옵션
  ///
  Widget _buildOption({
    required T option,
    required bool isSelected,
    required VoidCallback onTapped,
  }) {
    return InkWell(
      onTap: onTapped,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          color: isSelected ? AppColors.colorFFD7D0 : AppColors.colorF7F3EF,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: AppText(
          text: labelBuilder(option),
          textAlign: TextAlign.center,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
