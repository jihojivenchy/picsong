import 'dart:async';

import 'package:get/get.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/data/services/model/model_install_service.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/model_install/model_install_progress.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/screens/round_preparation/round_preparation_screen.dart';
import 'package:picsong/utils/services/app_logger.dart';

/// 모델 다운로드 화면 컨트롤러 — 온보딩을 건너뛴 사용자가 게임에 들어가려 할 때
class ModelDownloadController extends GetxController {
  /// 다운로드를 마치면 진입할 게임의 시대
  final Era era;

  /// 모델 설치 진행 스냅샷
  final Rx<ModelInstallProgress> installProgress =
      Rx<ModelInstallProgress>(ModelInstallProgress.initialState);

  /// 모델 설치 서비스
  final ModelInstallService _modelInstallService = ModelInstallService();

  /// 진행률 구독
  StreamSubscription<ModelInstallProgress>? _progressSubscription;

  ModelDownloadController({required this.era});

  @override
  void onInit() {
    super.onInit();
    _startInstall();
  }

  @override
  void onClose() {
    _progressSubscription?.cancel();
    super.onClose();
  }

  ///
  /// 실패 후 재시도
  ///
  void onRetryPressed() => _startInstall();

  ///
  /// 진행률 구독을 붙이고 네이티브 다운로드·설치를 시작
  ///
  Future<void> _startInstall() async {
    _progressSubscription ??= _modelInstallService.progressStream().listen(
          _onProgress,
          onError: _onInstallError,
        );
    try {
      await _modelInstallService.startInstall();
    } on ModelInstallException catch (error) {
      _onInstallError(error);
    }
  }

  ///
  /// 진행 스냅샷 반영 — 설치가 끝나면 곧바로 게임으로 보낸다
  ///
  void _onProgress(ModelInstallProgress progress) {
    installProgress.value = progress;
    if (progress.state == ModelInstallState.ready) _goToGame();
  }

  ///
  /// 설치 실패 반영
  ///
  void _onInstallError(Object error) {
    AppLogger.error('모델 설치 실패', error: error);
    installProgress.value = installProgress.value.copyWith(
      state: ModelInstallState.failed,
    );
  }

  ///
  /// 로딩(그림 생성) 화면으로 교체 이동 — 뒤로가기가 이 화면으로 돌아오지 않게 한다
  ///
  void _goToGame() => Get.off(() => RoundPreparationScreen(era: era));
}
