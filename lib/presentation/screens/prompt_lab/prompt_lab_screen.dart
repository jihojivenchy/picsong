import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_controller.dart';
import 'package:picsong/presentation/screens/prompt_lab/widgets/prompt_trial_item.dart';

///
/// 프롬프트 실험실 화면 (진단 전용)
/// 배치를 실기기에서 순서대로 생성해 원인을 가린다
///
/// 배치마다 별도 실험실로 뜬다 — 태그로 컨트롤러를 나눠 결과가 섞이지 않는다.
///
class PromptLabScreen extends BaseScreen<PromptLabController> {
  /// 이 실험실이 실행할 배치
  final PromptLabBatch batch;

  PromptLabScreen({super.key, required this.batch}) : super(tag: batch.tag);

  /// 뷰모델 초기화 — 이미 떠 있으면 이전 결과를 그대로 쓴다
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    if (Get.isRegistered<PromptLabController>(tag: batch.tag)) return;
    Get.put(
      PromptLabController(batch: batch),
      tag: batch.tag,
      permanent: true,
    );
  }

  /// 앱바 구성
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return DefaultAppBar(title: batch.title, centerTitle: true);
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Gap(height: AppSpacing.lg),
          _buildRunButton(),
          const Gap(height: AppSpacing.lg),
          Expanded(child: _buildTrialList()),
        ],
      ),
    );
  }

  /// 실행 버튼 — 진행 중에는 진척도를 표시한다
  Widget _buildRunButton() {
    return Obx(() {
      final bool isRunning = viewModel.isRunning.value;
      final int totalCount = viewModel.trialList.length;
      final String progress = '${viewModel.doneCount.value}/$totalCount';

      return AppButton(
        text: isRunning ? '생성 중 $progress' : '실험 $totalCount건 실행',
        disabled: isRunning,
        onTapped: viewModel.run,
      );
    });
  }

  /// 실험 결과 목록
  Widget _buildTrialList() {
    return Obx(() {
      final List<PromptTrial> trialList = viewModel.trialList;

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        itemCount: trialList.length,
        itemBuilder: (BuildContext context, int index) {
          return PromptTrialItem(trial: trialList[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Gap(height: AppSpacing.xxl);
        },
      );
    });
  }
}
