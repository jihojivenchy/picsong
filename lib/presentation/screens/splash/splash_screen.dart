import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/presentation/common/base/base_cubit_screen.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:picsong/presentation/screens/splash/splash_cubit.dart';
import 'package:picsong/presentation/screens/splash/widgets/splash_body.dart';

class SplashScreen extends BaseCubitScreen<SplashCubit> {
  const SplashScreen({super.key});

  /// 뷰모델 생성
  @override
  SplashCubit createViewModel(BuildContext context) => SplashCubit();

  /// 풀블리드 표시 위해 SafeArea/배경색 오버라이드
  @override
  bool get wrapWithSafeArea => false;

  @override
  Color backgroundColor(BuildContext context) => AppColors.surfaceCanvas;

  /// 스플래시 본문 — 연출이 끝나면 판정된 목적지로 전환한다
  @override
  Widget buildBody(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: _moveToDestination,
      child: SplashBody(onFinished: viewModel(context).resolveDestination),
    );
  }

  // MARK: - Helpers

  ///
  /// 판정된 목적지로 스택을 통째로 교체 — 스플래시로 되돌아올 수 없게 한다
  ///
  void _moveToDestination(BuildContext context, SplashState state) {
    switch (state.destination) {
      case null:
        return;
      case SplashDestination.home:
        const HomeRoute().go(context);
      case SplashDestination.onboarding:
        const OnboardingRoute().go(context);
    }
  }
}
