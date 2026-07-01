import 'dart:io';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/services.dart';
import 'package:picsong/utils/services/app_logger.dart';
import 'package:picsong/data/dio/dio_service.dart';
import 'package:picsong/data/dtos/auth/sign_in_response_dto.dart';
import 'package:picsong/domain/entities/auth/sign_up/social_provider.dart';

class KakaoAuthService {
  final DioService _dioService = DioService();
  final UserApi _serviceInstance = UserApi.instance;

  // 카카오 로그인 (카카오톡 -> 카카오계정 순서로 시도)
  Future<SignInResponseDTO> signIn() async {
    // 카카오톡 설치 여부 확인
    if (await isKakaoTalkInstalled()) {
      return await _signInWithKakaoTalk();
    } else {
      return await _signInWithKakaoAccount();
    }
  }

  // 카카오톡으로 로그인
  Future<SignInResponseDTO> _signInWithKakaoTalk() async {
    AppLogger.log('카카오톡으로 로그인 시도');

    try {
      // 1. 카카오톡으로 로그인
      OAuthToken token = await _serviceInstance.loginWithKakaoTalk();
      AppLogger.log('카카오톡으로 로그인 성공: ${token.accessToken}');

      // 2. SNS 로그인 요청
      final response = await _dioService.post(
        path: 'app/user/social/login',
        data: {
          'token': token.accessToken,
          'provider': SocialProvider.kakao.queryValue,
          'os': Platform.isAndroid ? 'GOOGLE' : 'APPLE',
        },
      );

      return SignInResponseDTO.fromJson(response);
    } on PlatformException catch (e) {
      // 카카오톡 미연결 상태 → 카카오계정 웹 로그인으로 전환
      if (e.code == 'NotSupportError') {
        AppLogger.log('카카오톡 미연결, 카카오계정 웹 로그인으로 전환');
        return await _signInWithKakaoAccount();
      }
      rethrow;
    }
  }

  // 카카오계정으로 로그인
  Future<SignInResponseDTO> _signInWithKakaoAccount() async {
    AppLogger.log('카카오계정으로 로그인 시도');

    OAuthToken token = await _serviceInstance.loginWithKakaoAccount();
    AppLogger.log('카카오계정으로 로그인 성공: ${token.accessToken}');

    // 2. SNS 로그인 요청
    final response = await _dioService.post(
      path: 'app/user/social/login',
      data: {
        'token': token.accessToken,
        'provider': SocialProvider.kakao.queryValue,
        'os': Platform.isAndroid ? 'GOOGLE' : 'APPLE',
      },
    );

    return SignInResponseDTO.fromJson(response);
  }

  /// 카카오 연동 해제
  /// SDK 토큰이 없는 경우는 디바이스에 카카오 인증 상태가 이미 없음을 의미하므로 SDK 호출을 건너뛰고 서버 호출만 진행
  Future<void> unlink() async {
    final token = await TokenManagerProvider.instance.manager.getToken();
    if (token == null) {
      AppLogger.log('카카오 SDK 토큰 없음: 서버 연동 해제만 진행');
      return;
    }
    await _serviceInstance.unlink();
  }

  ///
  /// 카카오 연동
  ///
  Future<void> connect() async {
    if (await isKakaoTalkInstalled()) {
      await connectWithKakaoTalk();
    } else {
      await connectWithKakaoAccount();
    }
  }

  ///
  /// 카카오톡으로 연동
  ///
  Future<void> connectWithKakaoTalk() async {
    AppLogger.log('카카오톡으로 연동 시도');

    try {
      // 1. 카카오톡으로 연동
      OAuthToken token = await _serviceInstance.loginWithKakaoTalk();
      AppLogger.log('카카오톡으로 연동 성공: ${token.accessToken}');

      // 2. 연동 요청
      await _dioService.post(
        path: 'app/user/social/connect',
        data: {
          'token': token.accessToken,
          'provider': SocialProvider.kakao.queryValue,
          'os': Platform.isAndroid ? 'GOOGLE' : 'APPLE',
        },
        tokenType: TokenType.access,
      );
    } on PlatformException catch (e) {
      // 카카오톡 미연결 상태 → 카카오계정 웹 로그인으로 전환
      if (e.code == 'NotSupportError') {
        AppLogger.log('카카오톡 미연결, 카카오계정 웹 로그인으로 전환');
        await connectWithKakaoAccount();
      }
      rethrow;
    }
  }

  ///
  /// 카카오계정으로 연동
  ///
  Future<void> connectWithKakaoAccount() async {
    AppLogger.log('카카오계정으로 연동 시도');

    OAuthToken token = await _serviceInstance.loginWithKakaoAccount();
    AppLogger.log('카카오계정으로 연동 성공: ${token.accessToken}');

    // 2. 연동 요청
    await _dioService.post(
      path: 'app/user/social/connect',
      data: {
        'token': token.accessToken,
        'provider': SocialProvider.kakao.queryValue,
        'os': Platform.isAndroid ? 'GOOGLE' : 'APPLE',
      },
      tokenType: TokenType.access,
    );
  }
}
