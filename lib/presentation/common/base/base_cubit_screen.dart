import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/presentation/common/base/base_screen.dart';

/// 뷰모델(Cubit)을 소유하는 화면의 베이스.
/// BlocProvider가 화면 수명에 맞춰 Cubit을 생성하고, 트리에서 빠질 때 자동 close한다.
@immutable
abstract class BaseCubitScreen<T extends Cubit<Object?>> extends BaseScreen {
  const BaseCubitScreen({super.key});

  ///
  /// 화면이 소유할 뷰모델 생성 — 초기 조회는 `Cubit(...)..fetchXxx()` 캐스케이드로 트리거
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
