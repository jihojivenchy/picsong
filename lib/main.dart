import 'dart:io';

import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/data/database/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:picsong/presentation/common/services/app_size.dart';
import 'package:picsong/presentation/router/router.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FCM 초기화
  // final FcmService fcmService = FcmService();
  // await fcmService.initialize();

  // Hive 초기화
  await initHive();

  // 시스템 UI 오버레이 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // iOS: 밝은 배경에 어두운 콘텐츠
      statusBarBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
      // Android: 밝은 배경에 어두운 아이콘
      statusBarIconBrightness:
          Platform.isIOS ? Brightness.dark : Brightness.light,
    )
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

/// 로컬 디비 초기화
Future<void> initHive() async {
  await Hive.initFlutter();
  await HiveService.instance.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static void _initLoadingIndicator() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.transparent
      ..boxShadow = []
      ..indicatorColor = AppColors.gray800
      ..maskType = EasyLoadingMaskType.black
      ..maskColor = Colors.transparent
      ..textColor = Colors.white
      ..dismissOnTap = false;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _initLoadingIndicator();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기
      },
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'Pic Song',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          brightness: Platform.isIOS ? Brightness.dark : Brightness.light,
        ),
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          fontFamily: 'Pretendard',
        ),
        builder: EasyLoading.init(builder: (context, child) {
          AppSize.init(context);

          return ToastificationWrapper(
            config: ToastificationConfig(
              animationDuration: Duration(milliseconds: 300),
              applyMediaQueryViewInsets: true,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            ),
          );
        }),
      ),
    );
  }
}
