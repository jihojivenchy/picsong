import 'package:get/get.dart';
import 'package:picsong/presentation/screens/auth/sign_in/sign_in_screen.dart';

import 'package:picsong/data/services/auth/auth_service.dart';

/// 유저 관련 글로벌 상태를 관리하는 싱글톤
class UserManager {
  static final UserManager instance = UserManager._internal();
  factory UserManager() => instance;
  UserManager._internal();

  final AuthService _authService = AuthService();

  /// 현재 로그인 여부
  final RxBool isLoggedIn = false.obs;

  /// 앱 시작 시 1회 호출하여 저장된 토큰으로 상태를 초기화
  Future<void> init() async {
    isLoggedIn.value = await _authService.isSignIn();
  }

  /// 로그아웃 처리
  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAll(() => const SignInScreen());
    isLoggedIn.value = false;
  }

  /// 로그인 상태 갱신
  Future<void> refresh() async {
    isLoggedIn.value = await _authService.isSignIn();
  }

  ///
  /// 회원탈퇴
  ///
  Future<void> withdraw() async {
    await _authService.withdraw();
    await signOut();
  }
}
