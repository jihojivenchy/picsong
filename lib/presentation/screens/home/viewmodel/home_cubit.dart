import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/error/error_exception_type.dart';
import 'package:picsong/data/services/model/model_install_service.dart';
import 'package:picsong/domain/entities/model_install/model_install_state.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';

part 'home_state.dart';

/// 홈 화면(시대 선택) 뷰모델
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  /// 안드로이드 뒤로가기 더블 탭 종료 간격
  static const Duration _exitConfirmDuration = Duration(seconds: 2);

  /// 모델 설치 서비스 — 게임 진입 전 모델 유무를 판정한다
  final ModelInstallService _modelInstallService = ModelInstallService();

  ///
  /// 모델 설치 상태 조회 — 조회에 실패하면 토스트로 알리고 null을 돌려준다
  ///
  Future<ModelInstallState?> fetchModelInstallState() async {
    try {
      return await _modelInstallService.fetchState();
    } on ModelInstallException catch (error) {
      AppToastService.show(error.message);
      return null;
    }
  }

  ///
  /// 안드로이드 한정: 2초 이내 재입력 시 앱 종료, 아니면 안내 토스트
  ///
  void handleBackPressed() {
    if (!Platform.isAndroid) return;
    final DateTime now = DateTime.now();
    if (_isExitConfirmed(lastPressedAt: state.lastBackPressedAt, now: now)) {
      SystemNavigator.pop();
      return;
    }
    emit(state.copyWith(lastBackPressedAt: now));
    AppToastService.show('한 번 더 누르면 종료됩니다');
  }

  ///
  /// 직전 뒤로가기가 종료 확인 간격 안에 있었는지 판정
  ///
  bool _isExitConfirmed({
    required DateTime? lastPressedAt,
    required DateTime now,
  }) {
    if (lastPressedAt == null) return false;
    return now.difference(lastPressedAt) < _exitConfirmDuration;
  }
}
