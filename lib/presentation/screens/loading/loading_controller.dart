import 'dart:async';

import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/screens/question/question_screen.dart';

/// 로딩(그림 생성) 화면 컨트롤러
class LoadingController extends GetxController {
  /// 그림 생성 연출 시간 (실제 생성 API 연동 전까지의 placeholder)
  static const Duration generationDuration = Duration(seconds: 3);

  /// 생성 대상 시대
  final Era era;

  /// 생성 완료 타이머
  Timer? _timer;

  LoadingController({required this.era});

  /// 화면 진입과 동시에 생성 카운트다운 시작
  @override
  void onInit() {
    super.onInit();
    _timer = Timer(generationDuration, onGenerationComplete);
  }

  /// 타이머 정리
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  ///
  /// 생성 완료 — 퀴즈 화면으로 진입
  ///
  void onGenerationComplete() {
    Get.off(() => QuestionScreen(era: era));
  }
}
