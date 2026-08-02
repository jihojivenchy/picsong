import 'package:picsong/domain/entities/model_install/model_install_state.dart';

/// 모델 설치 진행 스냅샷 — 네이티브 진행률 이벤트의 도메인 표현
class ModelInstallProgress {
  /// 설치 상태
  final ModelInstallState state;

  /// 수신한 바이트 수
  final int receivedBytes;

  /// 전체 바이트 수 — manifest 수신 전이면 0
  final int totalBytes;

  const ModelInstallProgress({
    required this.state,
    required this.receivedBytes,
    required this.totalBytes,
  });

  /// 초기 상태
  static ModelInstallProgress get initialState => const ModelInstallProgress(
        state: ModelInstallState.notInstalled,
        receivedBytes: 0,
        totalBytes: 0,
      );

  /// 진행 비율(0.0~1.0) — 분모(totalBytes)를 모르면 0
  double get ratio =>
      totalBytes > 0 ? (receivedBytes / totalBytes).clamp(0.0, 1.0).toDouble() : 0.0;

  factory ModelInstallProgress.fromJson(Map<String, dynamic> json) {
    return ModelInstallProgress(
      state: ModelInstallState.fromQueryValue(json['state'] as String?),
      receivedBytes: (json['receivedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
    );
  }

  ModelInstallProgress copyWith({
    ModelInstallState? state,
    int? receivedBytes,
    int? totalBytes,
  }) {
    return ModelInstallProgress(
      state: state ?? this.state,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}
