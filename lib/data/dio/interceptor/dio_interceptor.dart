import 'package:picsong/utils/services/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picsong/data/dio/dio_service.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/data/services/secure_storage/secure_storage_service.dart';
import 'package:picsong/data/dtos/auth/token_response_dto.dart';
import 'package:picsong/presentation/screens/auth/sign_in/sign_in_screen.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// 액세스 토큰 및 리프레시 토큰 로직을 위한 인터셉터
class DioInterceptor extends Interceptor {
  final SecureStorageService storage;

  DioInterceptor({
    required this.storage,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 액세스 토큰이 필요한 요청인지 체크
      if (options.extra['requiresAccessToken'] == true) {
        // 액세스 토큰 헤더에 담기
        final accessToken = await storage.get(SecureStorageKey.accessToken);
        options.headers['authorization'] = 'Bearer $accessToken';
      }

      // 리프레시 토큰이 필요한 요청인지 체크
      if (options.extra['requiresRefreshToken'] == true) {
        // 리프레시 토큰 헤더에 담기
        final refreshToken = await storage.get(SecureStorageKey.refreshToken);
        options.headers['refreshToken'] = refreshToken;
      }

      // 다음 인터셉터로 요청 전달
      handler.next(options);
    } catch (e) {
      // 토큰 없을 경우, 에러 발생
      handler.reject(
        DioException(
          requestOptions: options,
          error: TokenMissingException('로그아웃되었습니다. 다시 로그인해주세요.'),
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 에러가 아니면 기본 에러 처리
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    // 이미 토큰 리프레시 요청중인 경우 무한 루프 방지
    if (err.requestOptions.path == 'app/user/access-by-refresh') {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: TokenMissingException('토큰 갱신 중 오류가 발생했습니다.'),
          type: DioExceptionType.unknown,
        ),
      );
    }

    // 리프레시 토큰 가져오기
    final refreshToken = await storage.get(SecureStorageKey.refreshToken);

    // 리프레시 토큰 없을 경우, 에러 발생
    if (refreshToken == null) {
      await signOut();
      Get.offAll(() => const SignInScreen());
      
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: TokenMissingException('로그아웃되었습니다. 다시 로그인해주세요.'),
          type: DioExceptionType.unknown,
        ),
      );
    }

    // 새로운 인스턴스 생성
    final dio = Dio();
    dio.interceptors.add(
      TalkerDioLogger(
        talker: AppLogger.talker,
        settings: const TalkerDioLoggerSettings(
          printRequestData: true,
          printResponseData: true,
          printRequestHeaders: true,
          printResponseHeaders: false,
        ),
      ),
    );

    try {
      // 리프레시 토큰으로 새로운 액세스 토큰 발급 요청
      final response = await dio.post(
        '${BaseURLs.current}app/user/access-by-refresh',
        data: {
          'token': refreshToken,
        },
      );

      // 새로운 액세스 토큰 저장
      final responseMap = response.data['result']['accessToken'];
      final responseDTO = TokenResponseDTO.fromJson(responseMap);
      final newAccessToken = responseDTO.value;

      await storage.save(
        SecureStorageKey.accessToken,
        newAccessToken,
      );

      // 실패한 요청 작업에 새로운 액세스 토큰 담기
      final options = err.requestOptions;

      options.headers.addAll({
        'authorization': 'Bearer $newAccessToken',
      });

      // 재시도
      final retryResponse = await dio.fetch(options);
      return handler.resolve(retryResponse); // 기존 작업 말고, 재시도 작업을 응답으로 받으셈
    } on DioException catch (_) {
      // 새로운 액세스 토큰을 발급받아서 처리해도 에러가 발생한다면, 리프레시 토큰도 새로 갱신
      // 다시 로그인 해야함
      await signOut();
      Get.offAll(() => const SignInScreen());
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: TokenMissingException('토큰이 만료되었습니다.'),
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  ///
  /// 로그아웃
  ///
  Future<void> signOut() async {
    await Future.wait([
      storage.delete(SecureStorageKey.accessToken),
      storage.delete(SecureStorageKey.refreshToken),
      storage.delete(SecureStorageKey.userName),
      storage.delete(SecureStorageKey.userID),
    ]);
  }
}
