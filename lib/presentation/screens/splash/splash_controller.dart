import 'package:get/get.dart' hide Trans;

import '../home/home_screen.dart';

class SplashController extends GetxController {

  ///
  /// 스플래시 연출 종료 후 다음 화면으로 전환
  ///
  void onSplashFinished() {
    Get.offAll(() => const HomeScreen());
  }
}
