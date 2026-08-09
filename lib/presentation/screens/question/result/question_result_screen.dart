import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:picsong/presentation/screens/question/result/widgets/question_result_header.dart';
import 'package:picsong/presentation/screens/question/result/widgets/question_result_song_card.dart';
import 'package:picsong/presentation/screens/question/scene_detail.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/question_scene_view.dart';

///
/// 문제 결과 화면 — 정오 헤더 + 출제된 클루 그림 + 정답 곡·가사.
///
/// 진행 버튼은 다음으로 넘어가는 대신 `true`를 담아 pop한다 —
/// 다음 단계 판단은 이 화면을 띄운 퀴즈 화면이 한다.
///
class QuestionResultScreen extends BaseScreen {
  /// 진행 중인 시대
  final Era era;

  /// 공개할 문제 — 정답 곡과 출제된 가사
  final Question question;

  /// 문제에서 보여준 클루 이미지 경로 목록 — 빈 문자열이면 스켈레톤
  final List<String> imagePathList;

  /// 정답을 맞혔는지 여부 (false면 답안 공개)
  final bool isCorrect;

  /// 마지막 문제 여부 (true면 '결과 보기')
  final bool isLast;

  const QuestionResultScreen({
    super.key,
    required this.era,
    required this.question,
    required this.imagePathList,
    required this.isCorrect,
    required this.isLast,
  });

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: '결과',
      centerTitle: true,
      titleColor: AppColors.textStrong,
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문 — 헤더 + 클루 그림 + 곡 카드
  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  QuestionResultHeader(isCorrect: isCorrect),
                  QuestionSceneView(
                    sceneCount: question.lyricLine.sceneCount,
                    imagePathList: imagePathList,
                    onSceneTapped: (int index) => context.push(
                      const ImageDetailRoute().location,
                      extra: sceneDetailOf(
                        imagePathList: imagePathList,
                        index: index,
                      ),
                    ),
                  ),
                  const Gap(height: AppSpacing.lg),
                  QuestionResultSongCard(era: era, question: question),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
            ),
            child: AppButton(
              text: isLast ? '결과 보기' : '다음 문제',
              margin: 0,
              onTapped: () => context.pop(true),
            ),
          ),
        ],
      ),
    );
  }
}
