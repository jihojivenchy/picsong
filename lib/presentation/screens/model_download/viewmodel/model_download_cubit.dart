import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/error/error_exception_type.dart';
import 'package:picsong/data/services/model/model_install_service.dart';
import 'package:picsong/domain/entities/model_install/model_install_progress.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/utils/services/app_logger.dart';

part 'model_download_state.dart';

/// 모델 다운로드 화면 뷰모델 — 온보딩을 건너뛴 사용자가 게임에 들어가려 할 때
class ModelDownloadCubit extends Cubit<ModelDownloadState> {
  ModelDownloadCubit() : super(const ModelDownloadState());

  /// 모델 설치 서비스
  final ModelInstallService _modelInstallService = ModelInstallService();

  /// 진행률 구독
  StreamSubscription<ModelInstallProgress>? _progressSubscription;

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }

  ///
  /// 진행률 구독을 붙이고 네이티브 다운로드·설치를 시작 — 실패 후 재시도도 같은 경로를 탄다
  ///
  Future<void> startInstall() async {
    _progressSubscription ??= _modelInstallService.progressStream().listen(
          _setProgress,
          onError: _onInstallError,
        );
    try {
      await _modelInstallService.startInstall();
    } on ModelInstallException catch (error) {
      _onInstallError(error);
    }
  }

  ///
  /// 설치 실패 반영
  ///
  void _onInstallError(Object error) {
    AppLogger.error('모델 설치 실패', error: error);
    _setProgress(
      state.installProgress.copyWith(state: ModelInstallState.failed),
    );
  }

  ///
  /// 진행 스냅샷 반영 — 화면이 닫힌 뒤 도착한 이벤트는 버린다
  ///
  void _setProgress(ModelInstallProgress progress) {
    if (isClosed) return;
    emit(state.copyWith(installProgress: progress));
  }
}
