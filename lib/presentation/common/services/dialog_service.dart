import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogService {
  DialogService._();

  static void close() {
    final context = Get.context;
    if (context != null &&
        Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static void show({
    required Dialog dialog,
    bool? dismissible,
  }) {
    final context = Get.context;

    if (context != null) {
      showDialog(
        barrierDismissible: dismissible ?? true,
        context: context,
        builder: (_) => dialog,
      );
    }
  }

  static Future<void> asyncShow({
    required Dialog dialog,
    bool? dismissible,
  }) {
    final context = Get.context;

    if (context != null) {
      return Future.value(
        showDialog(
          barrierDismissible: dismissible ?? true,
          context: context,
          builder: (_) => dialog,
        ),
      );
    } else {
      return Future.value();
    }
  }
}
