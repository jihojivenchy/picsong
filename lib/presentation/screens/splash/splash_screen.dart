import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/common/base/legacy_base_screen.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/screens/splash/splash_controller.dart';
import 'package:picsong/presentation/screens/splash/widgets/splash_body.dart';

class SplashScreen extends LegacyBaseScreen<SplashController> {
  const SplashScreen({super.key});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(SplashController());
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<SplashController>();
    super.onDispose(context);
  }

  /// 풀블리드 표시 위해 SafeArea/배경색 오버라이드
  @override
  bool get wrapWithSafeArea => false;

  @override
  Color backgroundColor(BuildContext context) => AppColors.surfaceCanvas;

  /// 스플래시 본문
  @override
  Widget buildBody(BuildContext context) {
    return SplashBody(onFinished: viewModel.onSplashFinished);
  }
}
