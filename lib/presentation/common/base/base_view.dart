import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Scaffold 없이 라이프사이클만 제공하는 경량 베이스 위젯.
/// 뷰모델(Cubit)이 필요한 뷰는 BaseCubitView를 상속한다.
@immutable
abstract class BaseView extends StatelessWidget {
  const BaseView({super.key});

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
