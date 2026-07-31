import 'package:get/get.dart' hide Trans;
import 'package:picsong/data/database/hive_service.dart';

import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashController extends GetxController {

  ///
  /// 스플래시 연출 종료 후 다음 화면으로 전환
  /// 온보딩을 아직 보지 않았다면 온보딩으로 보낸다(최초 1회)
  ///
  void onSplashFinished() {
    if (_isOnboardingCompleted()) {
      Get.offAll(() => const HomeScreen());
      return;
    }
    Get.offAll(() => const OnboardingScreen());
  }

  ///
  /// 온보딩 완료 여부 조회
  ///
  bool _isOnboardingCompleted() {
    return HiveService.instance.get<bool>(
          HiveBoxPath.onboardingCompleted,
          defaultValue: false,
        ) ??
        false;
  }
}
