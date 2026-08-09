part of 'splash_cubit.dart';

/// 스플래시 연출이 끝난 뒤 이동할 곳
enum SplashDestination {
  /// 온보딩을 이미 마친 사용자
  home,

  /// 온보딩을 아직 보지 않은 사용자
  onboarding,
}

/// 스플래시 화면 상태
final class SplashState extends Equatable {
  const SplashState({this.destination});

  /// 이동할 곳 — 판정 전에는 null
  final SplashDestination? destination;

  SplashState copyWith({SplashDestination? destination}) {
    return SplashState(destination: destination ?? this.destination);
  }

  @override
  List<Object?> get props => <Object?>[destination];
}
