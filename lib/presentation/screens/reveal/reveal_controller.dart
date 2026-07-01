import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 정답 공개(reveal) 화면 컨트롤러
class RevealController extends GetxController {
  /// '다음 문제'/'결과 보기' 진행을 라운드 소유자에 위임하는 콜백
  final VoidCallback onNext;

  RevealController({required this.onNext});

  ///
  /// 다음 단계로 진행
  ///
  void goNext() => onNext();
}
