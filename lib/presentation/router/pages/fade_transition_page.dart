import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 페이드 전환 페이지 — 스플래시/온보딩/홈처럼 스택이 교체되는 라우트에 사용
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({required super.child, super.key})
      : super(
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: child,
          ),
        );
}
