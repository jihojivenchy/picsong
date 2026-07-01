import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:picsong/utils/services/app_logger.dart';

import 'package:get/get.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/presentation/global/user_manager.dart';
import 'package:picsong/data/services/auth/auth_service.dart';
import 'package:picsong/data/services/auth/kakao_auth_service.dart';
import 'package:picsong/domain/entities/auth/sign_up/sign_up_request.dart';
import 'package:picsong/presentation/screens/home/home_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../data/dtos/auth/sign_in_response_dto.dart';

class SignInController extends GetxController {
  final AuthService _authService = AuthService();
  final KakaoAuthService _kakaoService = KakaoAuthService();

  ///
  /// 구글 로그인
  ///
  Future<void> signInWithGoogle() async {
    EasyLoading.show();

    try {
      final responseDTO = await _authService.signInWithGoogle();
      _handleSignInResult(responseDTO);
    } catch (e) {
      AppLogger.error('구글 로그인 실패', error: e);
      AppToastService.show(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  ///
  /// 애플 로그인
  ///
  Future<void> signInWithApple() async {
    
    try {
      final responseDTO = await _authService.signInWithApple();
      _handleSignInResult(responseDTO);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        AppLogger.log('애플 로그인: 사용자가 취소했습니다');
        AppToastService.show('애플 로그인을 취소했습니다.');
        return;
      }
      AppLogger.error('애플 로그인 실패', error: e);
      AppToastService.show('애플 로그인에 실패했습니다. 다시 시도해주세요.');
    } catch (e) {
      AppLogger.error('애플 로그인 실패', error: e);
      AppToastService.show(e.toString());
    }
  }

  ///
  /// 네이버 로그인
  ///
  Future<void> signInWithNaver() async {
    EasyLoading.show();

    try {
      final responseDTO = await _authService.signInWithNaver();
      _handleSignInResult(responseDTO);
    } catch (e) {
      AppLogger.error('네이버 로그인 실패', error: e);
      AppToastService.show(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  ///
  /// 카카오 로그인
  ///
  Future<void> signInWithKakao() async {
    EasyLoading.show();

    try {
      final result = await _kakaoService.signIn();
      await _handleSignInResult(result);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        AppLogger.log('카카오 로그인: 사용자가 취소했습니다');
        AppToastService.show('카카오 로그인을 취소했습니다.');
        return;
      }
      AppLogger.error('카카오 로그인 중 문제가 발생했습니다', error: e);
      AppToastService.show('카카오 로그인에 실패했습니다. 다시 시도해주세요.');
    } catch (e) {
      AppLogger.error('카카오 로그인 중 문제가 발생했습니다', error: e);
      AppToastService.show(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  ///
  /// 로그인 결과 처리
  ///
  Future<void> _handleSignInResult(SignInResponseDTO responseDTO) async {
    switch (responseDTO.status) {
      // 회원가입 필요
      case UserAuthStatus.notRegistered:
        final signUpRequest = SignUpRequest.initialState.copyWith(
          signUpToken: responseDTO.signUpToken,
        );

        break;

      // 정상 로그인 상태
      case UserAuthStatus.normal:
        // 토큰이 있으면 저장
        if (responseDTO.accessToken != null &&
            responseDTO.refreshToken != null) {
          await _authService.saveToken(
            accessToken: responseDTO.accessToken!.value,
            refreshToken: responseDTO.refreshToken!.value,
          );
        }

        await UserManager.instance.refresh();
        AppToastService.show('로그인이 완료되었습니다.');
        Get.offAll(() => const HomeScreen());

        break;
    }
  }
}
