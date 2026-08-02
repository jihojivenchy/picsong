import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/badge/app_badge.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 점수대별 마무리 문구
typedef ScoreTone = ({String copy, String sub});

/// 라운드 결과
class RoundResultView extends StatelessWidget {
  /// 점수 숫자 크기
  static const double _scoreSize = 56;

  /// 점수 숫자 줄 높이
  static const double _scoreHeight = 60;

  /// 점수 숫자 등장 시 밀어 올리는 거리
  static const double _scoreRise = 6;

  /// 방금 진행한 시대
  final Era era;

  /// 맞힌 문제 수
  final int score;

  /// 전체 문제 수
  final int total;

  const RoundResultView({
    super.key,
    required this.era,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final ScoreTone tone = _toneOf(score);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppBadge(
            text: era.label,
            backgroundColor: era.softColor,
            textColor: era.color,
            borderRadius: 4,
            fontSize: 13,
          ),
          const Gap(height: AppSpacing.lg),
          _buildScore(),
          const Gap(height: AppSpacing.md),
          AppText(
            text: tone.copy,
            style: AppTypography.title3,
            color: AppColors.textStrong,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const Gap(height: AppSpacing.xs),
          AppText(
            text: tone.sub,
            style: AppTypography.body,
            color: AppColors.textMuted,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// 점수 — 맞힌 수를 크게, 분모는 작고 흐리게. 등장 시 페이드 + 살짝 상승
  Widget _buildScore() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppMotion.durationSlow,
      curve: AppMotion.emphasized,
      builder: (BuildContext context, double value, Widget? child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, _scoreRise * (1 - value)),
          child: child,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          AppText(
            text: '$score',
            style: AppTypography.display.copyWith(
              fontSize: _scoreSize,
              height: _scoreHeight / _scoreSize,
              letterSpacing: _scoreSize * -0.03,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
            color: AppColors.textStrong,
          ),
          AppText(
            text: ' / $total',
            style: AppTypography.title2,
            color: AppColors.textSubtle,
          ),
        ],
      ),
    );
  }

  /// 점수에 맞는 주 문구와 보조 문구 쌍
  ScoreTone _toneOf(int score) {
    if (score == total) {
      return (
        copy: '다섯 곡 모두 맞히셨어요',
        sub: '그림만 보고 이 정도라니, 그 시절이 선명하시네요.',
      );
    }
    if (score >= 3) {
      return (copy: '절반 넘게 맞히셨어요', sub: '헷갈리는 그림 속에서도 익숙한 노래를 잘 짚어냈어요.');
    }
    if (score >= 1) {
      return (
        copy: '${score == 1 ? '한' : '두'} 곡을 찾아내셨어요',
        sub: '아리송한 힌트 속에서도 단서를 찾아냈네요.',
      );
    }
    return (
      copy: '이번 그림들은 좀 어려웠어요',
      sub: 'AI가 흐릿하게 그린 날도 있어요. 한 번 더 해볼까요?',
    );
  }
}
