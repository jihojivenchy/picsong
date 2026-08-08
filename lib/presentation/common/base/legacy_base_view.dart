
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Scaffold 없이 컨트롤러만 바인딩하는 경량 베이스 위젯
@immutable
abstract class LegacyBaseView<T extends GetxController> extends GetView<T> {
  const LegacyBaseView({super.key, this.tag});

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
        /// 위젯 라이프사이클
        useEffect(() {
          onInit(context);
          return () => onDispose(context);
        }, []);

        return buildView(context);
      },
    );
  }

  /// 위젯 UI 구성
  @protected
  Widget buildView(BuildContext context);

  /// 위젯이 생성될 때 호출
  @protected
  void onInit(BuildContext context) {}

  /// 위젯이 사라질 때 호출
  @protected
  void onDispose(BuildContext context) {}
}
