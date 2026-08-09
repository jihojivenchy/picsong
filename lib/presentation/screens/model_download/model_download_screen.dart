import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/common/base/base_cubit_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:picsong/presentation/screens/model_download/model_download_cubit.dart';
import 'package:picsong/presentation/screens/model_download/widgets/model_download_body.dart';

/// 모델 다운로드 화면 — 완료 즉시 선택한 시대의 게임으로 들어간다
class ModelDownloadScreen extends BaseCubitScreen<ModelDownloadCubit> {
  /// 다운로드를 마치면 진입할 게임의 시대
  final Era era;

  const ModelDownloadScreen({super.key, required this.era});

  @override
  ModelDownloadCubit createViewModel(BuildContext context) =>
      ModelDownloadCubit()..startInstall();

  /// 닫기 버튼만 둔 앱바 — 나가도 다운로드는 백그라운드에서 계속된다
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const DefaultAppBar(
      title: '',
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문 — 설치가 끝나면 곧바로 게임으로 교체 이동한다(뒤로가기가 이 화면으로 돌아오지 않게)
  @override
  Widget buildBody(BuildContext context) {
    return BlocConsumer<ModelDownloadCubit, ModelDownloadState>(
      listenWhen: (ModelDownloadState previous, ModelDownloadState current) =>
          previous.installProgress.state != ModelInstallState.ready &&
          current.installProgress.state == ModelInstallState.ready,
      listener: (BuildContext context, ModelDownloadState state) =>
          RoundPreparationRoute(era: era.queryValue).pushReplacement(context),
      builder: (BuildContext context, ModelDownloadState state) {
        return ModelDownloadBody(
          progress: state.installProgress,
          onRetry: viewModel(context).startInstall,
        );
      },
    );
  }
}
