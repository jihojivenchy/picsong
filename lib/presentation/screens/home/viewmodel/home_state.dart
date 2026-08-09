part of 'home_cubit.dart';

/// 홈 화면 상태
final class HomeState extends Equatable {
  const HomeState({this.lastBackPressedAt});

  /// 마지막 뒤로가기 입력 시각 — 더블 탭 종료 판정용, 입력 전에는 null
  final DateTime? lastBackPressedAt;

  HomeState copyWith({DateTime? lastBackPressedAt}) {
    return HomeState(
      lastBackPressedAt: lastBackPressedAt ?? this.lastBackPressedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[lastBackPressedAt];
}
