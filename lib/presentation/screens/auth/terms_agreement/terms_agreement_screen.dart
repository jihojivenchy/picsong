import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/screens/auth/terms_agreement/terms_agreement_controller.dart';

/// 약관 동의 화면
class TermsAgreementScreen extends BaseScreen<TermsAgreementController> {
  const TermsAgreementScreen({super.key});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(TermsAgreementController());
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<TermsAgreementController>();
    super.onDispose(context);
  }

  /// 앱바 구성
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const DefaultAppBar(
      title: '약관 동의',
      centerTitle: true,
      fontSize: 16,
    );
  }

  /// Body 구성
  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [],
    );
  }
}
