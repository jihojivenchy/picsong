import 'package:get/get.dart';

/// 위치 권한 상태 변화를 감지하여 자동으로 데이터 갱신/초기화를 수행하는 컨트롤러 mixin
mixin LocationAwareMixin on GetxController {
  /// 위치 권한이 충족되었을 때 호출
  void onFetchReady();

  /// 위치 권한이 깨졌을 때 호출 (상태 초기화 시점)
  void onFetchNotReady();

  /// 직전 dispatch 시점의 _canFetch 값. 동일 상태 중복 발화를 막기 위해 사용
  bool? _wasCanFetch;


  /// 데이터 조회 가능 여부 (위치 권한 충족)
  // bool get _canFetch => LocationManager.instance.isLocationAvailable;

  /// 조회 가능 여부에 따라 적절한 훅으로 분기 (초기 진입/포커스 복귀 시 사용)
  // void refetch() {
  //   _canFetch ? onFetchReady() : onFetchNotReady();
  // }

  // /// _canFetch 값 변화에 따라 적절한 훅으로 분기 (상태 전이 시에만 발화)
  // void _dispatch() {
  //   final bool canFetch = _canFetch;
  //   if (_wasCanFetch == canFetch) return;
  //   _wasCanFetch = canFetch;
  //   canFetch ? onFetchReady() : onFetchNotReady();
  // }
}
