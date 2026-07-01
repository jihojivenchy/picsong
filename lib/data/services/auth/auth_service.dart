import 'dart:io';

import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:picsong/domain/entities/auth/sign_up/sign_up_request.dart';
import 'package:picsong/domain/entities/auth/sign_up/social_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:picsong/data/dio/dio_service.dart';
import 'package:picsong/data/dtos/auth/sign_up_response_dto.dart';
import 'package:picsong/data/dtos/auth/sign_in_response_dto.dart';
import 'package:picsong/data/services/secure_storage/secure_storage_service.dart';

import '../../dio/error/error_exception_type.dart';

class AuthService {
  final DioService _dioService = DioService();
  final SecureStorageService _storage = SecureStorageService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  ///
  /// 구글 로그인 진행
  ///
  Future<SignInResponseDTO> signInWithGoogle() async {
    // 1. 구글 로그인 진행
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // 만약 사용자가 구글 로그인을 취소했을 경우 (구글 로그인 실패)
    if (googleUser == null) {
      throw ServerException('구글 로그인 취소');
    }

    // 3. 인증 정보 가져오기
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 4. 인증 정보 확인
    if (googleAuth.accessToken == null) {
      throw ServerException('토큰 발급 실패');
    }

    // 5. 로그인 요청
    final response = await _dioService.post(
      path: 'app/user/social/login',
      data: {
        'token': googleAuth.accessToken!,
        'provider': SocialProvider.google.queryValue,
        'os': Platform.isAndroid ? "GOOGLE" : "APPLE",
      },
    );

    // 6. 로그인 응답 처리
    final responseDTO = SignInResponseDTO.fromJson(response);
    return responseDTO;
  }

  ///
  /// 애플 로그인
  ///
  Future<SignInResponseDTO> signInWithApple() async {
    // 1. 애플 로그인 진행
    final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // 2. SNS 로그인 요청
    final response = await _dioService.post(
      path: 'app/user/social/login',
      data: {
        'token': credential.authorizationCode,
        'provider': SocialProvider.apple.queryValue,
        'os': Platform.isAndroid ? "GOOGLE" : "APPLE",
      },
    );

    // 3. 로그인 응답 처리
    final responseDTO = SignInResponseDTO.fromJson(response);
    return responseDTO;
  }

  ///
  /// 네이버 로그인 진행
  ///
  Future<SignInResponseDTO> signInWithNaver() async {
    await FlutterNaverLogin.logOut();

    // 1. 네이버 로그인 진행
    final NaverLoginResult result = await FlutterNaverLogin.logIn();

    // 2. 로그인 상태 확인
    if (result.status != NaverLoginStatus.loggedIn) {
      throw ServerException('네이버 로그인 실패 또는 취소');
    }

    // 3. 토큰 확인
    final NaverToken token = await FlutterNaverLogin.getCurrentAccessToken();
    if (!token.isValid() || token.accessToken.isEmpty) {
      throw ServerException('네이버 토큰 발급 실패');
    }

    // 4. 로그인 요청
    final response = await _dioService.post(
      path: 'app/user/social/login',
      data: {
        'token': token.accessToken,
        'provider': SocialProvider.naver.queryValue,
        'os': Platform.isAndroid ? "GOOGLE" : "APPLE",
      },
    );

    // 5. 로그인 응답 처리
    final responseDTO = SignInResponseDTO.fromJson(response);
    return responseDTO;
  }

  ///
  /// 토큰 저장
  ///
  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.save(SecureStorageKey.accessToken, accessToken),
      _storage.save(SecureStorageKey.refreshToken, refreshToken),
    ]);
  }

  ///
  /// 액세스 토큰 저장
  ///
  Future<void> saveAccessToken({required String accessToken}) async {
    await _storage.save(SecureStorageKey.accessToken, accessToken);
  }

  ///
  /// 유저 이름 저장
  ///
  Future<void> saveUserName({required String userName}) async {
    await _storage.save(SecureStorageKey.userName, userName);
  }

  ///
  /// 유저 아이디 저장
  ///
  Future<void> saveUserID({required int userID}) async {
    await _storage.save(SecureStorageKey.userID, userID.toString());
  }

  ///
  /// 로그인 여부 확인
  ///
  Future<bool> isSignIn() async {
    var accessToken = await _storage.get(SecureStorageKey.accessToken);
    return accessToken != null && accessToken.isNotEmpty;
  }

  ///
  /// 토큰 삭제
  ///
  Future<void> deleteToken() async {
    await Future.wait([
      _storage.delete(SecureStorageKey.accessToken),
      _storage.delete(SecureStorageKey.refreshToken),
    ]);
  }

  ///
  /// 로그아웃
  ///
  Future<void> signOut() async {
    await Future.wait([
      _storage.delete(SecureStorageKey.accessToken),
      _storage.delete(SecureStorageKey.refreshToken),
      _storage.delete(SecureStorageKey.userName),
      _storage.delete(SecureStorageKey.userID),
    ]);
  }

  ///
  /// 회원가입
  ///
  Future<void> signUp({
    required SignUpRequest request,
  }) async {
    final response = await _dioService.post(
      path: 'app/user/sign-up',
      data: request.toJson(),
    );
    final responseDTO = SignUpResponseDTO.fromJson(response);
    await saveToken(
      accessToken: responseDTO.accessToken.value,
      refreshToken: responseDTO.refreshToken.value,
    );
  }

  /// 네이버 연동 해제
  Future<void> unlinkNaver() async {
    await FlutterNaverLogin.logOutAndDeleteToken();
  }

  /// 구글 연동 해제
  Future<void> unlinkGoogle() async {
    // 기기에 저장된 구글 자격증명을 조용히 복구 (앱 재실행 케이스 대응)
    await _googleSignIn.signInSilently();
    // 현재 로그인된 계정이 있을 때만 disconnect (없으면 이미 해제된 상태)
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.disconnect();
    }
  }

  ///
  /// 회원탈퇴
  ///
  Future<void> withdraw() async {
    
  }
}
