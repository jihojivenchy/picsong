import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:picsong/presentation/common/services/deep_link/deep_link_type.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  static DeepLinkService get instance => _instance;

  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  ///
  /// 초기화
  ///
  void initialize() {
    // 1. 앱이 종료되었을 때 -> 초기 링크 확인
    _checkInitialLink();

    // 2. 앱 실행 중 -> 링크 처리
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  ///
  /// 초기 링크 확인
  ///
  Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;

      _handleLink(uri);
    } catch (e) {
      debugPrint('DeepLink Error: $e');
    }
  }

  /// 외부에서 수집한 URI(예: QR 스캔)를 딥링크 흐름으로 위임
  void handleUri(Uri uri) => _handleLink(uri);

  ///
  /// 딥링크 처리
  ///
  void _handleLink(Uri uri) {
    debugPrint('DeepLink Received: $uri');

    // Query 파싱
    final String? typeString = uri.queryParameters['type'];
    final String? idString = uri.queryParameters['id'];

    if (typeString == null || idString == null) {
      log('DeepLink 파라미터가 부족합니다. $uri');
      return;
    }

    // ID 파싱
    final int? id = int.tryParse(idString);

    // ID가 null이면 처리하지 않음
    if (id == null) {
      log('DeepLink ID 형식이 잘못되었습니다. $uri');
      return;
    }

    // Type 파싱
    final type = DeepLinkType.fromLinkName(typeString);

    // 화면 이동
    switch (type) {
      case DeepLinkType.qr:
        break;
      case DeepLinkType.none:
        log('DeepLink 타입이 없습니다. $uri');
        break;
    }
  }

  /// 리소스 해제
  void dispose() {
    _linkSubscription?.cancel();
  }
}
