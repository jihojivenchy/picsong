// somewhere in request_options_helper.dart (or dio_utils.dart)
import 'package:dio/dio.dart';

/// 액세스 토큰 필요 옵션
Options withAccessToken() => Options(
      extra: {
        'requiresAccessToken': true,
      },
    );

/// 리프레시 토큰 필요 옵션
Options withRefreshToken() => Options(
      extra: {
        'requiresRefreshToken': true,
      },
    );

/// 액세스 토큰 및 리프레시 토큰 필요 옵션
Options withAuth({bool access = false, bool refresh = false}) => Options(
      extra: {
        if (access) 'requiresAccessToken': true,
        if (refresh) 'requiresRefreshToken': true,
      },
    );
