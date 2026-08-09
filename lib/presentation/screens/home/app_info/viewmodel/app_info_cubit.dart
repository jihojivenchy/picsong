import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/utils/services/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';

part 'app_info_state.dart';

/// 앱 정보 화면 뷰모델
class AppInfoCubit extends Cubit<AppInfoState> {
  AppInfoCubit() : super(const AppInfoState());

  /// 모델 저장소 주소 — 라이선스 전문·변경 내역이 여기 있다
  static const String modelRepositoryURL =
      'https://huggingface.co/jivenchy/sd-turbo-coreml-384-6bit';

  ///
  /// 패키지 정보에서 앱 버전을 읽어 상태에 반영
  ///
  Future<void> fetchVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      emit(state.copyWith(version: '${info.version} (${info.buildNumber})'));
    } catch (error) {
      AppLogger.error('앱 버전 조회 실패', error: error);
    }
  }

  ///
  /// 모델 저장소를 외부 브라우저로 연다
  ///
  Future<void> openRepository() async {
    try {
      await launchUrl(
        Uri.parse(modelRepositoryURL),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      AppLogger.error('저장소 링크 열기 실패', error: error);
      AppToastService.show('링크를 열지 못했어요');
    }
  }
}
