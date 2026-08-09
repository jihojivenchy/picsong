import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';
import 'package:picsong/presentation/screens/prompt_lab/viewmodel/prompt_lab_cubit.dart';
import 'package:picsong/presentation/screens/prompt_lab/widgets/prompt_trial_item.dart';

///
/// 프롬프트 실험실 화면 (진단 전용)
/// 배치를 실기기에서 순서대로 생성해 원인을 가린다
///
/// 배치마다 별도 실험실로 뜬다 — 배치별로 뷰모델을 나눠 결과가 섞이지 않는다.
///
class PromptLabScreen extends BaseScreen {
  /// 배치별 뷰모델 캐시 — 화면을 나가도 시험 결과가 남도록 일부러 살려둔다(진단 전용)
  static final Map<String, PromptLabCubit> _cubitCache =
      <String, PromptLabCubit>{};

  /// 이 실험실이 실행할 배치
  final PromptLabBatch batch;

  const PromptLabScreen({super.key, required this.batch});

  /// 캐시된 뷰모델을 그대로 물려준다 — `.value`는 화면이 빠져도 close하지 않는다
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromptLabCubit>.value(
      value: _cubitCache.putIfAbsent(
        batch.tag,
        () => PromptLabCubit(batch: batch),
      ),
      child: Builder(builder: (BuildContext context) => super.build(context)),
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
    return BlocBuilder<PromptLabCubit, PromptLabState>(
      buildWhen: (PromptLabState previous, PromptLabState current) =>
          previous.isRunning != current.isRunning ||
          previous.doneCount != current.doneCount,
      builder: (BuildContext context, PromptLabState state) {
        final int totalCount = state.trialList.length;
        final String progress = '${state.doneCount}/$totalCount';

        return AppButton(
          text: state.isRunning ? '생성 중 $progress' : '실험 $totalCount건 실행',
          disabled: state.isRunning,
          onTapped: context.read<PromptLabCubit>().run,
        );
      },
    );
  }

  /// 실험 결과 목록
  Widget _buildTrialList() {
    return BlocBuilder<PromptLabCubit, PromptLabState>(
      buildWhen: (PromptLabState previous, PromptLabState current) =>
          previous.trialList != current.trialList,
      builder: (BuildContext context, PromptLabState state) {
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          itemCount: state.trialList.length,
          itemBuilder: (BuildContext context, int index) {
            return PromptTrialItem(trial: state.trialList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Gap(height: AppSpacing.xxl);
          },
        );
      },
    );
  }
}
