import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/badge/app_badge.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 정답 곡 정보 카드 — 곡명·메타·시대 뱃지와 대표 가사(플레이스홀더).
class RevealSongCard extends StatelessWidget {
  /// 가사 플레이스홀더 (저작권상 실제 가사 대신 사용)
  static const String _lyricPlaceholder = '이 곡의 대표 가사 한 줄이 여기에 표시돼요';

  /// 곡이 속한 시대
  final Era era;

  /// 정답 곡
  final Song song;

  const RevealSongCard({super.key, required this.era, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHead(),
          _buildLyric(),
        ],
      ),
    );
  }

  /// 곡 정보 + 시대 뱃지
  Widget _buildHead() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _buildSongInfo()),
        const Gap(width: AppSpacing.md),
        AppBadge(
          text: era.label,
          backgroundColor: era.softColor,
          textColor: era.color,
          fontSize: 13,
        ),
      ],
    );
  }

  /// 라벨 + 곡명 + 가수·연도·장르
  Widget _buildSongInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: '이 그림이 담은 노래',
          style: AppTypography.caption,
          color: AppColors.textSubtle,
        ),
        const Gap(height: AppSpacing.xs),
        AppText(
          text: song.title,
          style: AppTypography.title2,
          color: AppColors.textStrong,
          maxLines: 2,
        ),
        const Gap(height: AppSpacing.xs),
        AppText(
          text: '${song.artist} · ${song.year}년 · ${song.genre}',
          style: AppTypography.body,
          color: AppColors.textBody,
          maxLines: 1,
        ),
      ],
    );
  }

  /// 대표 가사 — 구분선 + 음표 아이콘
  Widget _buildLyric() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.music_note_rounded,
            color: AppColors.textSubtle,
            size: 16,
          ),
          const Gap(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text: '"$_lyricPlaceholder"',
              style: AppTypography.body,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
