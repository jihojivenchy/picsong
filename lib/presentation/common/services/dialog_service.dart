import 'package:flutter/material.dart';
import 'package:picsong/presentation/router/router.dart';

class DialogService {
  DialogService._();

  static void close() {
    final context = rootNavigatorKey.currentContext;
    if (context != null &&
        Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static void show({
    required Dialog dialog,
    bool? dismissible,
  }) {
    final context = rootNavigatorKey.currentContext;

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
    final context = rootNavigatorKey.currentContext;

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
