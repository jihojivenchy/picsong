// GetX 컨트롤러 주입/수명주기 보조 유틸리티 확장입니다.
// - findOrPut: 기존 패턴 유지 (있으면 반환, 없으면 등록)
// - findOrPutWithRefCount / deleteWithRefCount: 다중 화면 공유를 위한 참조 카운팅 제공

import 'package:get/get.dart';

extension GetInterfaceExtension on GetInterface {
  /// 컨트롤러를 조회하고, 없으면 새로 등록
  /// - 기존 코드 호환용 기본 유틸
  T findOrPut<T extends GetxController>(
    T Function() creator, {
    String? tag,
    bool permanent = false,
  }) {
    return isRegistered<T>(tag: tag)
        ? find<T>(tag: tag)
        : put<T>(creator(), tag: tag, permanent: permanent);
  }

  /// 컨트롤러를 조회하되, 미등록 시 null 반환
  /// - find는 미등록 시 throw하므로 "있으면 사용 / 없으면 분기" 패턴에 사용
  T? findOrNull<T extends GetxController>({String? tag}) {
    return isRegistered<T>(tag: tag) ? find<T>(tag: tag) : null;
  }

  /// 참조 카운터 저장소
  static final Map<String, int> _referenceCounts = {};

  /// 참조 카운팅과 함께 컨트롤러 등록/조회
  /// - 동일한 타입/태그 조합으로 여러 화면에서 같은 컨트롤러를 공유할 때 사용
  /// - 기존 인스턴스가 있으면 참조 카운트만 +1 하고 그대로 반환
  /// - 없으면 생성 후 참조 카운트를 1로 설정
  /// - 공유 컨트롤러가 라우트 pop에 의해 자동 제거되지 않도록 permanent 사용을 권장합니다.
  T findOrPutWithRefCount<T extends GetxController>(
    T Function() creator, {
    String? tag,
    bool permanent = false,
  }) {
    final key = _configureKey<T>(tag);

    // 기존 인스턴스 존재 → 참조 카운트 증가 후 반환
    if (isRegistered<T>(tag: tag)) {
      _referenceCounts[key] = (_referenceCounts[key] ?? 0) + 1;
      return find<T>(tag: tag);
    } else {
      // 신규 생성 → 참조 카운트 1로 초기화 후 등록
      _referenceCounts[key] = 1;
      return put<T>(creator(), tag: tag, permanent: permanent);
    }
  }

  ///
  /// 참조 카운팅과 함께 컨트롤러를 삭제합니다.
  /// - 참조 카운트가 1 이하일 때만 실제로 삭제
  /// - 그 외에는 카운트만 감소시키고 인스턴스를 유지
  /// - 반환값: 실제 삭제되면 true, 아니면 false
  bool deleteWithRefCount<T extends GetxController>({String? tag}) {
    final key = _configureKey<T>(tag);
    final currentCount = _referenceCounts[key] ?? 0;

    if (currentCount <= 1) {
      _referenceCounts.remove(key);
      delete<T>(tag: tag, force: true);
      return true;
    } else {
      _referenceCounts[key] = currentCount - 1;
      return false;
    }
  }

  /// 타입 + 태그 조합으로 키 구성
  String _configureKey<T>(String? tag) {
    final t = tag?.trim();

    // null 혹은 빈 문자열 → 'default'
    if (t == null || t.isEmpty) {
      return '${T.toString()}:default';
    }
    
    // 그 외 그대로 사용
    return '${T.toString()}:$t';
  }
}
