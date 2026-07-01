
import 'package:flutter/material.dart';

extension NumExtension on num {
  /// 디바이스 ratio에 맞는 이미지 캐시 사이즈 계산
  int cacheSize(BuildContext context) {  
    return (this * MediaQuery.of(context).devicePixelRatio).round();  
  }  
}