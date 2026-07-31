import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/home/home_controller.dart';
import 'package:picsong/presentation/screens/home/widgets/era_item.dart';
import 'package:picsong/presentation/screens/home/widgets/home_header.dart';

/// 홈 화면
class HomeScreen extends BaseScreen<HomeController> {
  const HomeScreen({super.key});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(HomeController());
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<HomeController>();
    super.onDispose(context);
  }

  /// 기본 pop 차단 (안드로이드 더블백 종료)
  @override
  bool get canPop => false;

  /// 뒤로가기 처리
  @override
  void onWillPop(BuildContext context) {
    viewModel.handleBackPressed();
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
          const HomeHeader(),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: Era.values.length,
              itemBuilder: (BuildContext context, int index) {
                final Era era = Era.values[index];

                return EraItem(
                  era: era,
                  onTap: () => viewModel.onEraSelected(era),
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
}
