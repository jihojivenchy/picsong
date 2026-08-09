import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/presentation/common/base/base_cubit_screen.dart';
import 'package:picsong/presentation/common/services/dialog_service.dart';
import 'package:picsong/presentation/design_system/components/dialog/app_dialog.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:picsong/presentation/screens/onboarding/viewmodel/onboarding_cubit.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/onboarding_top_bar.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/download/onboarding_download_gate_step.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/download/onboarding_downloading_step.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/intro/onboarding_intro_step.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/second/onboarding_on_device_step.dart';

/// 온보딩(최초 1회) 화면 — 4스텝을 한 화면 안에서 전환한다
class OnboardingScreen extends BaseCubitScreen<OnboardingCubit> {
  const OnboardingScreen({super.key});

  @override
  OnboardingCubit createViewModel(BuildContext context) => OnboardingCubit();

  /// 화면 본문 — 온보딩이 끝나면(건너뛰기·설치 완료) 홈으로 스택을 교체한다
  @override
  Widget buildBody(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (OnboardingState previous, OnboardingState current) =>
          !previous.isCompleted && current.isCompleted,
      listener: (BuildContext context, OnboardingState state) =>
          const HomeRoute().go(context),
      child: Column(
        children: <Widget>[
          _buildTopBar(),
          Expanded(child: _buildStepPageView(context)),
        ],
      ),
    );
  }

  /// 상단 진행바 + 건너뛰기 — 다운로드가 시작되면 건너뛸 수 없다
  Widget _buildTopBar() {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (OnboardingState previous, OnboardingState current) =>
          previous.step != current.step,
      builder: (BuildContext context, OnboardingState state) {
        return OnboardingTopBar(
          progress: state.step.progress,
          onSkip:
              state.step.canSkip ? viewModel(context).completeOnboarding : null,
        );
      },
    );
  }

  /// 스텝 본문 — 스와이프를 막고 스텝 이동으로만 넘긴다
  Widget _buildStepPageView(BuildContext context) {
    return PageView(
      controller: viewModel(context).pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        OnboardingIntroStep(onNext: viewModel(context).onNextPressed),
        OnboardingOnDeviceStep(onNext: viewModel(context).onNextPressed),
        OnboardingDownloadGateStep(
          onDownload: () => _showDownloadConfirmDialog(context),
        ),
        _buildDownloadingStep(),
      ],
    );
  }

  /// Step 4 — 모델 다운로드 진행 상태
  Widget _buildDownloadingStep() {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (OnboardingState previous, OnboardingState current) =>
          previous.installProgress != current.installProgress,
      builder: (BuildContext context, OnboardingState state) {
        return OnboardingDownloadingStep(
          progress: state.installProgress,
          onRetry: viewModel(context).startInstall,
        );
      },
    );
  }

  // MARK: - Bottom Sheets & Dialogs

  ///
  /// 다운로드 시작 전 확인 다이얼로그 — 동의하면 뷰모델 다운로드를 시작한다
  ///
  void _showDownloadConfirmDialog(BuildContext context) {
    DialogService.show(
      dialog: AppDialog.doubleButton(
        title: '다운로드 확인',
        subTitle: '다운로드 중에는 데이터가 사용될 수 있어요.\nWi-Fi 환경에서 받는 것을 권장합니다.',
        leftButtonContent: '취소',
        rightButtonContent: '다운로드',
        onLeftButtonTapped: DialogService.close,
        onRightButtonTapped: () {
          DialogService.close();
          viewModel(context).onDownloadPressed();
        },
      ),
    );
  }
}
