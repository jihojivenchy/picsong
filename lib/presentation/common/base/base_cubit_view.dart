import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/presentation/common/base/base_view.dart';

/// 뷰모델(Cubit)을 소유하는 경량 뷰의 베이스.
/// 탭 내부 페이지처럼 Scaffold 없이 Cubit 수명만 위젯 트리에 맞출 때 사용한다.
@immutable
abstract class BaseCubitView<T extends Cubit<Object?>> extends BaseView {
  const BaseCubitView({super.key});

  ///
  /// 뷰가 소유할 뷰모델 생성 — 초기 조회는 `Cubit(...)..fetchXxx()` 캐스케이드로 트리거
  ///
  @protected
  T createViewModel(BuildContext context);

  /// 뷰모델 접근
  @protected
  T viewModel(BuildContext context) => context.read<T>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: createViewModel,
      child: Builder(builder: (context) => super.build(context)),
    );
  }
}
