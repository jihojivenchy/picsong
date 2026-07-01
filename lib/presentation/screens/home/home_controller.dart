import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/presentation/screens/loading/loading_screen.dart';

/// 홈 화면(시대 선택) 컨트롤러
class HomeController extends GetxController {
  /// 안드로이드 뒤로가기 더블 탭 종료 간격
  static const Duration _exitConfirmDuration = Duration(seconds: 2);

  /// 마지막 뒤로가기 입력 시각
  DateTime? _lastBackAt;

  /// 시대 선택 — 로딩(그림 생성) 화면으로 진입
  void onEraSelected(Era era) {
    Get.to(() => LoadingScreen(era: era));
  }

  /// 안드로이드 한정: 2초 이내 재입력 시 앱 종료, 아니면 안내 토스트
  void handleBackPressed() {
    if (!Platform.isAndroid) return;
    final DateTime now = DateTime.now();
    if (_lastBackAt != null &&
        now.difference(_lastBackAt!) < _exitConfirmDuration) {
      SystemNavigator.pop();
      return;
    }
    _lastBackAt = now;
    AppToastService.show('한 번 더 누르면 종료됩니다');
  }
}
