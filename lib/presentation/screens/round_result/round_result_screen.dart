import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question_result.dart';
import 'package:picsong/presentation/common/base/legacy_base_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/round_result/widgets/round_result_view.dart';
import 'package:picsong/presentation/screens/round_result/widgets/round_result_row.dart';

/// 라운드 결과 화면 — 점수 요약 + 문제별 정오 리스트.
class RoundResultScreen extends LegacyBaseScreen {
  /// 방금 진행한 시대
  final Era era;

  /// 문제별 결과 (출제 순서)
  final List<QuestionResult> resultList;

  const RoundResultScreen({
    super.key,
    required this.era,
    required this.resultList,
  });

  /// 라운드가 끝나 돌아갈 곳이 없다 — 기본 pop 차단
  @override
  bool get canPop => false;

  /// 안드로이드 뒤로가기도 홈 복귀로 처리
  @override
  void onWillPop(BuildContext context) => _goHome();

  /// 뒤로가기 없는 가운데 정렬 앱바
  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: '라운드 결과',
      centerTitle: true,
      titleColor: AppColors.textStrong,
      backgroundColor: AppColors.surfaceCanvas,
      isShowBackButton: false,
    );
  }

  /// 화면 본문 — 스크롤 영역(히어로 + 리스트) + 하단 고정 액션
  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: _buildScrollArea()),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: AppButton(text: '홈으로', margin: 0, onTapped: _goHome),
        ),
      ],
    );
  }

  /// 히어로와 문제별 리스트
  Widget _buildScrollArea() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RoundResultView(
            era: era,
            score: _correctCount,
            total: resultList.length,
          ),
          ..._buildRowList(),
        ],
      ),
    );
  }

  /// 문제별 결과 행 — 첫 행만 구분선 없이
  List<Widget> _buildRowList() {
    return resultList.indexed
        .map(
          ((int, QuestionResult) entry) => RoundResultRow(
            result: entry.$2,
            hasTopDivider: entry.$1 > 0,
          ),
        )
        .toList();
  }

  /// 맞힌 문제 수
  int get _correctCount =>
      resultList.where((QuestionResult result) => result.isCorrect).length;

  /// 라운드 스택을 모두 걷어내고 홈으로
  void _goHome() => Get.until((Route<dynamic> route) => route.isFirst);
}
