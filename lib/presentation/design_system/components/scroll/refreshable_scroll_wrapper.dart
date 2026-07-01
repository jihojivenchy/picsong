import 'package:flutter/material.dart';

/// 작은 콘텐츠(EmptyView/ErrorView 등)에서도 풀-투-리프레시가 동작하도록
/// 뷰포트를 채우는 스크롤 래퍼
class RefreshableScrollWrapper extends StatelessWidget {
  const RefreshableScrollWrapper({super.key, required this.child});

  /// 스크롤 영역에 표시할 자식 위젯
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
