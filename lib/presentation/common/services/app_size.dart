import 'package:flutter/material.dart';

class AppSize {
  AppSize._();

  static bool _isInitialized = false; // 초기화 상태 확인 변수

  static late double statusBarHeight; // Safe Area 상단 Inset
  static late double bottomInset; // Safe Area 하단 Inset
  static late double screenWidth; // 디바이스 넓이
  static late double screenHeight; // 디바이스 높이

  // 반응형 하단 Safe Area 하단 Inset
  static double get responsiveBottomInset =>
      bottomInset == 0.0 ? 16.0 : bottomInset;

  // 초기화
  static void init(BuildContext context) async {
    if (_isInitialized) return;
    statusBarHeight = MediaQuery.paddingOf(context).top;
    bottomInset = MediaQuery.paddingOf(context).bottom;
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    _isInitialized = true;
  }
}
