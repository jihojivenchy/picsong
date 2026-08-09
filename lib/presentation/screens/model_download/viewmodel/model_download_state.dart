part of 'model_download_cubit.dart';

/// 모델 다운로드 화면 상태
final class ModelDownloadState extends Equatable {
  /// 모델 설치 진행 스냅샷
  final ModelInstallProgress installProgress;

  const ModelDownloadState({
    this.installProgress = const ModelInstallProgress(
      state: ModelInstallState.notInstalled,
      receivedBytes: 0,
      totalBytes: 0,
    ),
  });

  ModelDownloadState copyWith({ModelInstallProgress? installProgress}) {
    return ModelDownloadState(
      installProgress: installProgress ?? this.installProgress,
    );
  }

  @override
  List<Object?> get props => <Object?>[installProgress];
}
