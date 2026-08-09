import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/common/base/base_cubit_screen.dart';
import 'package:picsong/presentation/common/services/dialog_service.dart';
import 'package:picsong/presentation/design_system/components/dialog/app_dialog.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:picsong/presentation/screens/home/viewmodel/home_cubit.dart';
import 'package:picsong/presentation/screens/home/widgets/era_item.dart';
import 'package:picsong/presentation/screens/home/widgets/home_header.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';

/// 홈 화면
class HomeScreen extends BaseCubitScreen<HomeCubit> {
  const HomeScreen({super.key});

  /// 뷰모델 생성
  @override
  HomeCubit createViewModel(BuildContext context) => HomeCubit();

  /// 기본 pop 차단 (안드로이드 더블백 종료)
  @override
  bool get canPop => false;

  /// 뒤로가기 처리
  @override
  void onWillPop(BuildContext context) =>
      viewModel(context).handleBackPressed();

  /// 프롬프트 실험실 진입 — 진단 전용, 원인 규명이 끝나면 제거한다
  @override
  Widget? get buildFloatingActionButton {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildLabButton(
          batch: PromptLabBatches.first,
          icon: Icons.looks_one_outlined,
        ),
        const Gap(height: AppSpacing.sm),
        _buildLabButton(
          batch: PromptLabBatches.second,
          icon: Icons.looks_two_outlined,
        ),
      ],
    );
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeHeader(
            onInfoTapped: () => const AppInfoRoute().push(context),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: Era.values.length,
              itemBuilder: (BuildContext context, int index) {
                final Era era = Era.values[index];

                return EraItem(
                  era: era,
                  onTap: () => _onEraSelected(context, era),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Gap(height: AppSpacing.md);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 실험실 하나로 이동하는 버튼 — heroTag가 겹치면 Flutter가 죽는다
  Widget _buildLabButton({
    required PromptLabBatch batch,
    required IconData icon,
  }) {
    // FAB는 context 없는 게터에서 만들어져, 이동에 쓸 context를 여기서 얻는다.
    return Builder(
      builder: (BuildContext context) => FloatingActionButton.small(
        heroTag: batch.tag,
        onPressed: () => PromptLabRoute(tag: batch.tag).push(context),
        child: Icon(icon),
      ),
    );
  }

  // MARK: - Bottom Sheets & Dialogs

  ///
  /// 모델 다운로드 유도 다이얼로그 — 취소하면 홈에 머문다
  ///
  void _showModelRequiredDialog(BuildContext context, Era era) {
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
          ModelDownloadRoute(era: era.queryValue).push(context);
        },
      ),
    );
  }

  // MARK: - Helpers

  ///
  /// 시대 선택 — 모델 설치 상태에 따라 라운드/다운로드/안내로 갈린다
  ///
  Future<void> _onEraSelected(BuildContext context, Era era) async {
    final ModelInstallState? installState =
        await viewModel(context).fetchModelInstallState();
    if (!context.mounted || installState == null) return;
    switch (installState) {
      // 모델 설치 완료
      case ModelInstallState.ready:
        RoundPreparationRoute(era: era.queryValue).push(context);

      // 모델 다운로드 중 또는 설치 중
      case ModelInstallState.downloading:
      case ModelInstallState.installing:
        ModelDownloadRoute(era: era.queryValue).push(context);

      // 모델 설치 실패 또는 미설치
      case ModelInstallState.notInstalled:
      case ModelInstallState.failed:
        _showModelRequiredDialog(context, era);
    }
  }
}
