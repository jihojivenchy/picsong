import 'package:picsong/presentation/design_system/components/toast/app_toast_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

abstract class AppToastService {
  AppToastService._();

  static void show(String text) {
    final context = Get.context;

    if (context != null) {
      toastification.showCustom(
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
        animationDuration: const Duration(milliseconds: 260),
        builder: (BuildContext context, ToastificationItem holder) {
          return AppToastWidget(text: text);
        },
      );
    }
  }
}
