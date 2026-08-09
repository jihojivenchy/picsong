import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/database/hive_service.dart';

part 'splash_state.dart';

/// 스플래시 화면 뷰모델
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

  ///
  /// 스플래시 연출 종료 후 갈 곳을 판정해 상태로 노출
  /// 온보딩을 아직 보지 않았다면 온보딩으로 보낸다(최초 1회)
  ///
  void resolveDestination() {
    emit(
      state.copyWith(
        destination: _isOnboardingCompleted()
            ? SplashDestination.home
            : SplashDestination.onboarding,
      ),
    );
  }

  ///
  /// 온보딩 완료 여부 조회
  ///
  bool _isOnboardingCompleted() {
    return HiveService.instance.get<bool>(
          HiveBoxPath.onboardingCompleted,
          defaultValue: false,
        ) ??
        false;
  }
}
