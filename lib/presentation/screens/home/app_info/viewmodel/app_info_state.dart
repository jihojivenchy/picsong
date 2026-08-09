part of 'app_info_cubit.dart';

/// 앱 정보 화면 상태
final class AppInfoState extends Equatable {
  const AppInfoState({this.version = ''});

  /// 앱 버전 — 조회 전에는 비어 있다
  final String version;

  AppInfoState copyWith({String? version}) {
    return AppInfoState(version: version ?? this.version);
  }

  @override
  List<Object?> get props => <Object?>[version];
}
