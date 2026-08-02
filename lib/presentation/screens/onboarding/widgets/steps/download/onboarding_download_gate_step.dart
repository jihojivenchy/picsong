import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/onboarding_step_layout.dart';

/// 온보딩 Step 3 — 다운로드 안내 + 동의
class OnboardingDownloadGateStep extends StatelessWidget {
  /// 주 액션 버튼 높이 (디자인시스템 Button lg)
  static const double _actionButtonHeight = 60;

  /// 고지 행 아이콘 타일 크기
  static const double _tileSize = 44;

  /// 고지 행 아이콘 크기
  static const double _iconSize = 22;

  /// 모델 다운로드 시작
  final VoidCallback onDownload;

  const OnboardingDownloadGateStep({super.key, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(height: AppSpacing.lg),
          const AppText(
            text: '마지막 준비물,\n그림 도구를 받아주세요',
            style: AppTypography.title1,
            color: AppColors.textStrong,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.md),
          const AppText(
            text: '폰이 직접 그리려면 그림 그리는 AI 모델이 필요해요. 한 번만 받아두면 계속 쓸 수 있어요.',
            style: AppTypography.bodyLg,
            color: AppColors.textMuted,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.xxl),
          _buildNoticeRow(
            icon: Icons.cloud_download_rounded,
            title: '약 1GB를 받아요',
            caption: '처음 한 번만 받으면 돼요',
          ),
          const Gap(height: AppSpacing.md),
          _buildNoticeRow(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi 연결을 권장해요',
            caption: '셀룰러로 받으면 데이터 사용량이 커요',
          ),
          const Gap(height: AppSpacing.md),
          _buildNoticeRow(
            icon: Icons.storage_rounded,
            title: '저장 공간 1GB 이상이 필요해요',
            caption: '공간이 부족하면 설치에 실패할 수 있어요',
          ),
        ],
      ),
      foot: AppButton(
        text: '모델 다운로드',
        height: _actionButtonHeight,
        fontSize: AppTypography.title3.fontSize,
        fontWeight: FontWeight.w600,
        margin: 0,
        onTapped: onDownload,
      ),
    );
  }

  /// 고지 행 — 아이콘 타일 + 제목 + 설명
  Widget _buildNoticeRow({
    required IconData icon,
    required String title,
    required String caption,
  }) {
    return Row(
      children: <Widget>[
        Container(
          width: _tileSize,
          height: _tileSize,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: _iconSize, color: AppColors.primary),
        ),
        const Gap(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppText(
                text: title,
                style: AppTypography.label,
                color: AppColors.textStrong,
              ),
              const Gap(height: 2),
              AppText(
                text: caption,
                style: AppTypography.caption,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
