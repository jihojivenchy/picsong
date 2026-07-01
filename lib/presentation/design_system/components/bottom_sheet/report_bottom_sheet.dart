import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/text_field/app_textfield.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 신고 바텀 시트
class ReportBottomSheet extends StatefulWidget {
  final Function(String reason) onReportButtonTapped;

  const ReportBottomSheet({
    super.key,
    required this.onReportButtonTapped,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String _reason = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600), // 최대 높이 제한
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(height: 10),
              Container(
                width: 34,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.gray30,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Gap(height: AppSpacing.xl),
              AppText(
                text: '신고하기',
                fontSize: 20,
              ),
              const Gap(height: AppSpacing.sm),
              AppText(
                text: '신고 사유를 입력해주세요',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              const Gap(height: AppSpacing.sm),
              AppTextField(
                onChanged: (text) => setState(() => _reason = text),
                fillColor: Colors.white,
                hintText: '신고 사유를 입력해주세요',
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              const Gap(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AppText(
                  text: '${_reason.length} / 50',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Gap(height: 30),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '취소',
                      textColor: Colors.black,
                      color: Colors.grey[100],
                      fontWeight: FontWeight.w400,
                      onTapped: () {
                        Get.back<void>();
                      },
                    ),
                  ),
                  const Gap(width: 10),
                  Expanded(
                    child: AppButton(
                      text: '신고',
                      textColor: Colors.white,
                      color: AppColors.reportRed,
                      fontWeight: FontWeight.w400,
                      onTapped: () {
                        widget.onReportButtonTapped(_reason);
                        Get.back<void>();
                      },
                    ),
                  ),
                ],
              ),
              const Gap(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
