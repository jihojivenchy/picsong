import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/screens/model_download/model_download_controller.dart';
import 'package:picsong/presentation/screens/model_download/widgets/model_download_body.dart';

/// 모델 다운로드 화면 — 완료 즉시 선택한 시대의 게임으로 들어간다
class ModelDownloadScreen extends BaseScreen<ModelDownloadController> {
  /// 다운로드를 마치면 진입할 게임의 시대
  final Era era;

  const ModelDownloadScreen({super.key, required this.era});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(ModelDownloadController(era: era));
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<ModelDownloadController>();
    super.onDispose(context);
  }

  /// 닫기 버튼만 둔 앱바 — 나가도 다운로드는 백그라운드에서 계속된다
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const DefaultAppBar(
      title: '',
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return Obx(
      () => ModelDownloadBody(
        progress: viewModel.installProgress.value,
        onRetry: viewModel.onRetryPressed,
      ),
    );
  }
}
