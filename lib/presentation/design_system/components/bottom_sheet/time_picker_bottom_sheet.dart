import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class TimePickerBottomSheet extends HookWidget {
  const TimePickerBottomSheet({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  final DateTime initialTime;
  final Function(DateTime) onTimeSelected;

  /// 바텀 시트 표시
  static void show(
    BuildContext context, {
    required DateTime initialTime,
    required Function(DateTime) onTimeSelected,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return TimePickerBottomSheet(
          initialTime: initialTime,
          onTimeSelected: onTimeSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 시간
    final tempSelectedTime = useState<DateTime>(initialTime);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: _buildTimeSelector(tempSelectedTime),
          ),
          const Gap(height: AppSpacing.xxl),
          _buildSubmitButton(tempSelectedTime.value),
          const Gap(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // 헤더 영역
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: '시간 선택',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close, size: 24, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  ///
  /// 시간 선택기
  ///
  Widget _buildTimeSelector(ValueNotifier<DateTime> tempTime) {
    return SizedBox(
      height: 200,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              fontSize: 20,
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: initialTime,
          onDateTimeChanged: (DateTime newTime) {
            tempTime.value = newTime;
          },
          use24hFormat: false,
          minuteInterval: 1,
        ),
      ),
    );
  }

  // 선택 완료 버튼
  Widget _buildSubmitButton(DateTime selectedTime) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: AppButton(
          text: '선택 완료',
          margin: 0,
          height: 50,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
          onTapped: () {
            onTimeSelected(selectedTime);
            Get.back();
          },
        ),
      ),
    );
  }
}
