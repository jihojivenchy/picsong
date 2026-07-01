
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/presentation/screens/auth/sign_in/sign_in_controller.dart';

import '../../../common/base/base_screen.dart';

/// 
class SignInScreen extends BaseScreen<SignInController> {
  const SignInScreen({super.key});

  @override
  void onInit(BuildContext context) {
    Get.put(SignInController());
  }

  @override
  void onDispose(BuildContext context) {
    Get.delete<SignInController>();
  }

  @override
  Widget buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
        ],
      ),
    );
  }
}
