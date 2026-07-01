import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';
import 'package:picsong/presentation/screens/auth/sign_up/sign_up_controller.dart';

/// 회원가입 화면
class SignUpScreen extends BaseScreen<SignUpController> {
  const SignUpScreen({super.key});

  /// 뷰모델 초기화
  @override
  void onInit(BuildContext context) {
    super.onInit(context);
    Get.put(SignUpController());
  }

  /// 뷰모델 해제
  @override
  void onDispose(BuildContext context) {
    Get.delete<SignUpController>();
    super.onDispose(context);
  }

  /// 앱바 구성
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: '회원가입',
      centerTitle: true,
      isShowBackButton: true,
      actions: [],
    );
  }

  /// Body 구성
  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      ],
    );
  }
}
