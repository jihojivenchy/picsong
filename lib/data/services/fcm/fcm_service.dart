import 'dart:convert';
import 'dart:io';
import 'package:picsong/utils/services/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:picsong/data/dio/dio_service.dart';
import 'package:picsong/data/services/secure_storage/secure_storage_service.dart';

/// 안드로이드 알림 채널 상수
abstract class AndroidChannelConstants {
  static const androidChannelID = 'high_importance_channel';
  static const androidChannelName = 'High Importance Notifications';
  static const androidChannelDesc = '기본 알림 채널';
}

/// FCM 푸시 알림 서비스
/// 토큰 관리, 포그라운드/백그라운드 메시지 처리, 로컬 알림 표시를 담당
class FcmService {
  /// Firebase 메시징 인스턴스
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 저장소 (토큰 저장용)
  final SecureStorageService _storage = SecureStorageService();

  /// 로컬 알림 플러그인 (포그라운드 알림 표시용)
  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // ---------- 초기화 ----------

  ///
  /// FCM 초기화 및 권한 요청
  ///
  Future<void> initialize() async {
    try {
      // 백그라운드 메시지 핸들러 등록 (main runApp 이전에 호출해야 함)
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 로컬 알림 초기화
      await _initializeLocalNotifications();

      // 알림 권한 상태 확인 (권한 요청은 PermissionService에서 중앙 처리)
      final NotificationSettings settings =
          await _messaging.getNotificationSettings();
      AppLogger.log('알림 권한 상태: ${settings.authorizationStatus}');

      // FCM 토큰 갱신 리스너 등록
      _messaging.onTokenRefresh.listen((updatedToken) {
        AppLogger.log('FCM 토큰 갱신: $updatedToken');
        _syncFcmToken(updatedToken: updatedToken);
      });

      // 메시지 리스너 등록
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 백그라운드 상태에서 알림 탭으로 앱 복귀 시 처리
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // TODO: - 알림 탭으로 앱 복귀 시 처리
      });

      // 앱 종료 상태에서 알림 탭으로 실행된 경우 처리
      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        // TODO: - 앱 종료 상태에서 알림 탭으로 실행 시 처리
      }
    } catch (e) {
      AppLogger.error('FCM 초기화 오류', error: e);
    }
  }

  // ---------- 권한 획득 후 활성화 ----------

  ///
  /// 알림 권한 획득 후 FCM 토큰 동기화
  ///
  Future<void> activateAfterPermission() async {
    try {
      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        await _waitForApnsToken();
      }
      await _syncFcmToken();
    } catch (e) {
      AppLogger.error('FCM 권한 후 활성화 오류', error: e);
    }
  }

  // ---------- 토큰 관리 ----------

  ///
  /// APNs 토큰이 준비될 때까지 대기
  ///
  Future<void> _waitForApnsToken() async {
    const maxRetries = 10;
    const retryInterval = Duration(milliseconds: 500);

    for (int i = 0; i < maxRetries; i++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          AppLogger.log('APNs 토큰 준비 완료');
          return;
        }
      } catch (e) {
        AppLogger.error('APNs 토큰 확인 시도 ${i + 1}/$maxRetries', error: e);
      }

      if (i < maxRetries - 1) {
        await Future.delayed(retryInterval);
      }
    }
  }

  ///
  /// FCM 토큰 동기화 (로컬 저장 + 서버 전달)
  ///
  Future<void> _syncFcmToken({String? updatedToken}) async {
    try {
      // 업데이트된 토큰이 있으면 사용, 없으면 현재 토큰 가져오기
      final token = updatedToken ?? await _messaging.getToken();

      // 토큰이 없을 경우
      if (token == null) {
        AppLogger.log('FCM 토큰 없음');
        return;
      }

      // 토큰 저장 및 서버로 전달
      await Future.wait([
        _storage.save(SecureStorageKey.fcmToken, token),
        _updateFcmToken(token),
      ]);
    } catch (e) {
      AppLogger.error('FCM 토큰 동기화 오류', error: e);
    }
  }

  ///
  /// FCM 토큰 업데이트 (서버로 전달)
  ///
  Future<void> _updateFcmToken(String fcmToken) async {
    final accessToken = await _storage.get(SecureStorageKey.accessToken);
    if (accessToken == null) {
      AppLogger.log('액세스 토큰 없음 FCM 토큰 업데이트 중단');
      return;
    }
    try {
      final dioService = DioService();
      await dioService.patch(
        path: 'app/user/fcm-token',
        data: {'fcmToken': fcmToken},
        tokenType: TokenType.access,
      );
      AppLogger.log('FCM 토큰 업데이트 완료');
    } catch (e) {
      AppLogger.error('FCM 토큰 업데이트 오류', error: e);
    }
  }

  // ---------- 로컬 알림 (포그라운드 처리) ----------

  ///
  /// 로컬 알림 초기화
  ///
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    await _ensureAndroidNotificationsPermission();
  }

  ///
  /// 안드로이드 알림 권한 확인
  /// Android 13+ 부터 알림 권한을 런타임으로 허용받아야 함
  ///
  Future<void> _ensureAndroidNotificationsPermission() async {
    if (!Platform.isAndroid) return;

    /// 안드로이드 플러터 로컬 알림 플러그인
    final androidPlugin = _notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    /// 알림 채널 생성
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        AndroidChannelConstants.androidChannelID,
        AndroidChannelConstants.androidChannelName,
        description: AndroidChannelConstants.androidChannelDesc,
        importance: Importance.high,
        showBadge: true,
      ),
    );
    // 알림 권한 요청은 PermissionService에서 중앙 처리
  }

  ///
  /// 로컬 알림 탭 처리
  ///
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    // ignore: unused_local_variable
    final Map<String, dynamic> data = jsonDecode(response.payload!);
    // TODO: - 알림 탭 처리 (data 기반 화면 이동)
  }

  ///
  /// 포그라운드 메시지 수신 시 로컬 알림으로 표시
  ///
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AndroidChannelConstants.androidChannelID,
        AndroidChannelConstants.androidChannelName,
        channelDescription: AndroidChannelConstants.androidChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationPlugin.show(
        message.hashCode,
        message.notification?.title ?? '알림',
        message.notification?.body ?? '',
        notificationDetails,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
    } catch (e) {
      AppLogger.error('로컬 알림 표시 오류', error: e);
    }
  }
}

// ---------- 백그라운드 처리 ----------

///
/// 백그라운드 메시지 핸들러
/// 별도 isolate에서 실행되므로 Firebase 재초기화 필요
///
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
