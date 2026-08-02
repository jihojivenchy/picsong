import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 라운드 준비 캡션
class PreparationCaption extends HookWidget {
  /// 캡션 최대 너비
  static const double _maxWidth = 280;

  /// 경과 시간(초)에 따라 넘어갈 문구들 — 앞의 임계값을 넘으면 그 문구로 바뀐다
  static const List<int> _thresholdList = <int>[15, 40];

  /// 첫 문구 — 기다리는 동안 읽을거리가 되는 시대 이야기
  final String trivia;

  const PreparationCaption({super.key, required this.trivia});

  @override
  Widget build(BuildContext context) {
    // 경과 시간에 따른 문구 단계
    final int step = _useCaptionStep();

    // 문구 선택
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final String caption = _captionOf(step);

    // 캡션 표시
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: AnimatedSwitcher(
        duration: reduce ? Duration.zero : AppMotion.durationBase,
        child: AppText(
          key: ValueKey<int>(step),
          text: caption,
          textAlign: TextAlign.center,
          style: AppTypography.body,
          color: AppColors.textMuted,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  /// 단계에 해당하는 문구
  String _captionOf(int step) {
    switch (step) {
      case 2:
        return '거의 다 됐어요. 조금만 더 기다려 주세요';
      case 1:
        return '처음 그릴 때는 AI 준비에 시간이 조금 걸려요';
      default:
        return trivia;
    }
  }

  ///
  /// 경과 시간에 따른 문구 단계 — 단계가 바뀔 때만 다시 그린다.
  ///
  int _useCaptionStep() {
    // 문구 단계 상태
    final ValueNotifier<int> step = useState<int>(0);

    useEffect(() {
      // 경과 시간 카운트
      int elapsed = 0;

      // 경과 시간 카운트 타이머
      final Timer timer = Timer.periodic(const Duration(seconds: 1), (Timer _) {
        // 경과 시간 증가
        elapsed++;

        // 경과 시간에 따른 문구 단계 업데이트
        final int next = _thresholdList.where((int t) => elapsed >= t).length;

        // 경과 시간에 따른 문구 단계 업데이트
        if (next != step.value) step.value = next;
      });

      // 경과 시간 카운트 타이머 취소
      return timer.cancel;
    }, const <Object>[]);

    // 문구 단계 반환
    return step.value;
  }
}
