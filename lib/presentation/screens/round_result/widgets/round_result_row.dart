import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/question/question_result.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 라운드 결과 리스트의 한 행 — 정오 글리프 + 곡 제목 + 곡 메타.
class RoundResultRow extends StatelessWidget {
  /// 정오 글리프가 차지하는 폭
  static const double _markWidth = 20;

  /// 정오 글리프 크기
  static const double _markSize = 18;

  /// 표시할 문제 결과
  final QuestionResult result;

  /// 위쪽 구분선 표시 여부 (첫 행은 그리지 않는다)
  final bool hasTopDivider;

  const RoundResultRow({
    super.key,
    required this.result,
    required this.hasTopDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: hasTopDivider
            ? const Border(top: BorderSide(color: AppColors.borderSubtle))
            : null,
      ),
      child: Row(
        children: <Widget>[
          _buildMark(),
          const Gap(width: AppSpacing.md),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// 정오 글리프 — 배경·테두리 없이 색만으로 구분
  Widget _buildMark() {
    return SizedBox(
      width: _markWidth,
      child: Icon(
        result.isCorrect ? Icons.check_rounded : Icons.close_rounded,
        size: _markSize,
        color: result.isCorrect ? AppColors.success : AppColors.error,
      ),
    );
  }

  /// 곡 제목 + 메타 두 줄
  Widget _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: result.question.song.title,
          style: AppTypography.bodyLg,
          fontWeight: FontWeight.w600,
          color: AppColors.textStrong,
          maxLines: 1,
        ),
        const Gap(height: 2),
        _buildMeta(),
      ],
    );
  }

  /// 가수·연도·장르
  Widget _buildMeta() {
    final Song song = result.question.song;

    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: '${song.artist} · ${song.year}년 · ${song.genre}',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
