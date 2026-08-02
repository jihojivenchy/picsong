import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/model_install/model_install_progress.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 모델 다운로드 본문 — 받는 중 → 설치 중 → 실패(재시도)
class ModelDownloadBody extends StatelessWidget {
  /// 주 액션 버튼 높이 (디자인시스템 Button lg)
  static const double _actionButtonHeight = 60;

  /// 진행 바 두께
  static const double _progressBarHeight = 8;

  /// 설치 진행 스냅샷
  final ModelInstallProgress progress;

  /// 실패 후 재시도
  final VoidCallback onRetry;

  const ModelDownloadBody({
    super.key,
    required this.progress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // 실패 상태
    final bool isFailed = progress.state == ModelInstallState.failed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(height: AppSpacing.lg),
          AppText(
            text: _title(progress.state),
            style: AppTypography.title1,
            color: AppColors.textStrong,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.md),
          AppText(
            text: _caption(progress.state),
            style: AppTypography.bodyLg,
            color: AppColors.textMuted,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.xxl),
          if (!isFailed) ..._buildProgressSection(),
          const Spacer(),
          if (isFailed)
            AppButton(
              text: '다시 시도',
              height: _actionButtonHeight,
              fontSize: AppTypography.title3.fontSize,
              fontWeight: FontWeight.w600,
              margin: 0,
              onTapped: onRetry,
            ),
        ],
      ),
    );
  }

  /// 상태별 제목
  String _title(ModelInstallState state) {
    switch (state) {
      case ModelInstallState.failed:
        return '다운로드에 실패했어요';
      case ModelInstallState.installing:
        return '설치하고 있어요';
      default:
        return 'AI 그림 도구를\n다운로드하고 있어요';
    }
  }

  /// 상태별 설명 — 다 받으면 곧바로 게임이 시작된다는 걸 알려준다
  String _caption(ModelInstallState state) {
    switch (state) {
      case ModelInstallState.failed:
        return '네트워크와 저장 공간을 확인하고 다시 시도해 주세요.';
      case ModelInstallState.installing:
        return '거의 다 됐어요. 곧 게임이 시작돼요.';
      default:
        return '백그라운드에서도 다운로드는 지속됩니다.\n설치가 완료되면 바로 게임이 시작돼요.';
    }
  }

  /// 진행률 표시 — 분모를 알기 전에는 미정 바만 보여준다
  List<Widget> _buildProgressSection() {
    final bool isIndeterminate =
        progress.state == ModelInstallState.installing ||
            progress.totalBytes == 0;
    return <Widget>[
      if (!isIndeterminate) ...<Widget>[
        AppText(
          text: '${(progress.ratio * 100).floor()}%',
          style: AppTypography.display,
          color: AppColors.primary,
        ),
        const Gap(height: AppSpacing.md),
      ],
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: LinearProgressIndicator(
          value: isIndeterminate ? null : progress.ratio,
          minHeight: _progressBarHeight,
          color: AppColors.primary,
          backgroundColor: AppColors.primarySoft,
        ),
      ),
      if (!isIndeterminate) ...<Widget>[
        const Gap(height: AppSpacing.sm),
        AppText(
          text:
              '${_formatBytes(progress.receivedBytes)} / ${_formatBytes(progress.totalBytes)}',
          style: AppTypography.caption,
          color: AppColors.textMuted,
        ),
      ],
    ];
  }

  /// 바이트를 읽기 좋은 단위로 — 1000MB 미만은 정수 MB, 이상은 소수 1자리 GB (1024 기준)
  String _formatBytes(int bytes) {
    const int mb = 1024 * 1024;
    const int gb = mb * 1024;
    if (bytes >= 1000 * mb) return '${(bytes / gb).toStringAsFixed(1)}GB';
    return '${bytes ~/ mb}MB';
  }
}
