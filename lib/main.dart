import 'dart:io';

import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/data/database/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:picsong/presentation/common/services/app_size.dart';
import 'package:picsong/presentation/screens/splash/splash_screen.dart';
import 'package:picsong/utils/services/native_log_bridge.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 네이티브 로그를 터미널에서 보이게 연결
  NativeLogBridge.listen();

  WidgetsBinding.instance.addObserver(_DeepLinkRouteObserver());

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
      child: GetMaterialApp(
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
        home: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: SplashScreen(),
        ),
      ),
    );
  }
}


/// Flutter framework router로 들어오는 딥링크 요청을 true로 반환처리
/// GetX 라우팅 처리로 인해 순수 router가 확인을 못받는 문제를 해결하기 위함
class _DeepLinkRouteObserver extends WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async => true;
}
