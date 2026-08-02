import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/data/services/model/model_install_service.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/presentation/common/services/dialog_service.dart';
import 'package:picsong/presentation/design_system/components/dialog/app_dialog.dart';
import 'package:picsong/presentation/screens/home/app_info/app_info_screen.dart';
import 'package:picsong/presentation/screens/round_preparation/round_preparation_screen.dart';
import 'package:picsong/presentation/screens/model_download/model_download_screen.dart';

/// 홈 화면(시대 선택) 컨트롤러
class HomeController extends GetxController {
  /// 안드로이드 뒤로가기 더블 탭 종료 간격
  static const Duration _exitConfirmDuration = Duration(seconds: 2);

  /// 모델 설치 서비스 — 게임 진입 전 모델 유무를 판정한다
  final ModelInstallService _modelInstallService = ModelInstallService();

  /// 마지막 뒤로가기 입력 시각
  DateTime? _lastBackAt;

  ///
  /// 시대 선택
  ///
  Future<void> onEraSelected(Era era) async {
    // 모델 설치 상태
    final ModelInstallState state;

    try {
      // 모델 설치 상태 조회
      state = await _modelInstallService.fetchState();
    } on ModelInstallException catch (error) {
      AppToastService.show(error.message);
      return;
    }

    switch (state) {
      // 모델 설치 완료
      case ModelInstallState.ready:
        Get.to(() => RoundPreparationScreen(era: era));

      // 모델 다운로드 중 또는 설치 중
      case ModelInstallState.downloading:
      case ModelInstallState.installing:
        Get.to(() => ModelDownloadScreen(era: era));

      // 모델 설치 실패 또는 미설치
      case ModelInstallState.notInstalled:
      case ModelInstallState.failed:
        _showModelRequiredDialog(era);
    }
  }

  ///
  /// 앱 정보 화면으로 이동
  ///
  void onInfoTapped() => Get.to(() => const AppInfoScreen());

  ///
  /// 모델 다운로드 유도 다이얼로그 — 취소하면 홈에 머문다
  ///
  void _showModelRequiredDialog(Era era) {
    DialogService.show(
      dialog: AppDialog.doubleButton(
        title: '다운로드 필요',
        subTitle: '게임을 시작하기 위해서는\n모델을 먼저 다운받아야 해요.\n'
            '\n· 모델 크기: 약 1 GB\n· 저장 공간: 1 GB 이상\n· 네트워크: Wi-Fi 권장',
        leftButtonContent: '취소',
        rightButtonContent: '다운로드',
        onLeftButtonTapped: DialogService.close,
        onRightButtonTapped: () {
          DialogService.close();
          Get.to(() => ModelDownloadScreen(era: era));
        },
      ),
    );
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
