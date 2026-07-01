
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

@immutable
abstract class BaseScreen<T extends GetxController> extends GetView<T> {
  const BaseScreen({super.key, this.tag});

  @override
  final String? tag;

  // GetView의 controller가 tag를 사용하도록 정의
  @override
  T get controller => Get.find<T>(tag: tag);

  /// 뷰모델
  @protected
  T get viewModel => controller;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(
      builder: (context) {
        /// 화면 라이프사이클
        useEffect(() {
          onInit(context);
          return () => onDispose(context);
        }, []);

        // 앱의 라이플 사이클 변화를 처리
        useOnAppLifecycleStateChange((previousState, state) {
          switch (state) {
            case AppLifecycleState.resumed:
              onResumed(context);
              break;
            case AppLifecycleState.paused:
              onPaused(context);
              break;
            case AppLifecycleState.inactive:
              onInactive(context);
              break;
            case AppLifecycleState.detached:
              onDetached(context);
              break;
            case AppLifecycleState.hidden:
              break;
          }
        });

        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            onWillPop(context);
          },
          child: Scaffold(
            extendBody: extendBody,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            appBar: buildAppBar(context),
            body: wrapWithSafeArea
                ? SafeArea(
                    top: setTopSafeArea,
                    bottom: setBottomSafeArea,
                    child: buildBody(context),
                  )
                : buildBody(context),
            backgroundColor: backgroundColor(context),
            bottomNavigationBar: buildBottomNavigationBar(context),
            floatingActionButtonLocation: floatingActionButtonLocation,
            floatingActionButton: buildFloatingActionButton,
          ),
        );
      },
    );
  }

  /// 앱바 구성
  @protected
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  /// Body 구성
  @protected
  Widget buildBody(BuildContext context);

  /// 하단 네비게이션 바 구성
  @protected
  Widget? buildBottomNavigationBar(BuildContext context) => null;

  /// 플로팅 액션 버튼 위치 설정
  @protected
  FloatingActionButtonLocation? get floatingActionButtonLocation => null;

  /// 플로팅 액션 버튼 구성
  @protected
  Widget? get buildFloatingActionButton => null;

  /// 화면의 배경색 설정
  @protected
  Color backgroundColor(BuildContext context) {
    return AppColors.surfaceCanvas;
  }

  /// 키보드가 나타날 때 화면 크기 조정 설정
  @protected
  bool get resizeToAvoidBottomInset => true;

  /// 바디 확장 설정
  @protected
  bool get extendBody => false;

  /// 앱바 뒤로 바디가 확장될 수 있는지 설정
  @protected
  bool get extendBodyBehindAppBar => false;

  /// SafeArea 사용 여부
  @protected
  bool get wrapWithSafeArea => true;

  /// SafeArea 상단 설정
  @protected
  bool get setTopSafeArea => true;

  /// SafeArea 하단 설정
  @protected
  bool get setBottomSafeArea => true;

  /// Swipe Back 제스처 동작을 막는지 여부를 설정
  @protected
  bool get canPop => true;

  /// will pop시
  @protected
  void onWillPop(BuildContext context) {}

  /// 화면이 생성될 때 호출
  @protected
  void onInit(BuildContext context) {}

  /// 화면이 사라질 때 호출 
  @protected
  void onDispose(BuildContext context) {}

  /// 화면이 다시 활성화될 때 호출 (Background => Foreground)
  @protected
  void onResumed(BuildContext context) {}

  /// 화면이 일시정지될 때 호출 (Foreground => Background)
  @protected
  void onPaused(BuildContext context) {}

  /// 화면이 비활성화될 때 호출 (Foreground => Background)
  @protected
  void onInactive(BuildContext context) {}

  /// 화면이 분리될 때 호출 (Foreground => Background)
  @protected
  void onDetached(BuildContext context) {}
}
