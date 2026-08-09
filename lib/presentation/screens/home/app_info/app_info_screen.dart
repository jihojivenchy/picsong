import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/presentation/common/base/base_cubit_screen.dart';
import 'package:picsong/presentation/design_system/components/bar/default_app_bar.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/home/app_info/app_info_cubit.dart';
import 'package:picsong/presentation/screens/home/app_info/widgets/app_info_section.dart';

/// 앱 정보 화면 — Stability AI 라이선스 표시 의무를 이행하는 자리
class AppInfoScreen extends BaseCubitScreen<AppInfoCubit> {
  /// 🚨 라이선스 §4a(iii)가 요구하는 지정 문구 — **번역·변형 금지**
  static const String _poweredBy = 'Powered by Stability AI';

  /// 🚨 라이선스 §4a(ii)가 요구하는 지정 문구 — **글자 그대로여야 한다. 번역 금지**
  static const String _stabilityNotice =
      'This Stability AI Model is licensed under the Stability AI Community '
      'License, Copyright © Stability AI Ltd. All Rights Reserved';

  const AppInfoScreen({super.key});

  /// 뷰모델 생성 — 진입과 동시에 앱 버전을 조회한다
  @override
  AppInfoCubit createViewModel(BuildContext context) =>
      AppInfoCubit()..fetchVersion();

  /// 앱바
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return const DefaultAppBar(
      title: '정보',
      backgroundColor: AppColors.surfaceCanvas,
    );
  }

  /// 화면 본문
  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAppSection(),
          const Gap(height: AppSpacing.xl),
          _buildModelSection(context),
          const Gap(height: AppSpacing.xl),
          _buildOpenSourceSection(),
        ],
      ),
    );
  }

  /// 앱 이름과 버전
  Widget _buildAppSection() {
    return AppInfoSection(
      title: '앱',
      children: <Widget>[
        const AppText(
          text: '픽송',
          style: AppTypography.title3,
          color: AppColors.textStrong,
        ),
        const Gap(height: AppSpacing.xs),
        _buildVersionText(),
      ],
    );
  }

  /// 버전 표시 — 조회가 끝나면 이 텍스트만 다시 그린다
  Widget _buildVersionText() {
    return BlocBuilder<AppInfoCubit, AppInfoState>(
      builder: (BuildContext context, AppInfoState state) => AppText(
        text: state.version.isEmpty ? '버전 확인 중' : '버전 ${state.version}',
        style: AppTypography.body,
        color: AppColors.textMuted,
      ),
    );
  }

  /// AI 모델 출처와 라이선스 고지 — 라이선스 의무 구간
  Widget _buildModelSection(BuildContext context) {
    return AppInfoSection(
      title: 'AI 모델',
      children: <Widget>[
        const AppText(
          text: _poweredBy,
          style: AppTypography.title3,
          color: AppColors.textStrong,
        ),
        const Gap(height: AppSpacing.sm),
        const AppText(
          text: '그림은 이 기기 안에서 만들어집니다. sd-turbo 모델을 Apple Core ML로 '
              '변환하고 6비트로 양자화해 사용합니다.',
          style: AppTypography.body,
          color: AppColors.textMuted,
          overflow: TextOverflow.visible,
        ),
        const Gap(height: AppSpacing.lg),
        const AppText(
          text: _stabilityNotice,
          style: AppTypography.caption,
          color: AppColors.textSubtle,
          overflow: TextOverflow.visible,
        ),
        const Gap(height: AppSpacing.lg),
        _buildRepositoryLink(context),
      ],
    );
  }

  /// 라이선스 전문·변경 내역이 있는 저장소로 이동
  Widget _buildRepositoryLink(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => viewModel(context).openRepository(),
      child: const Row(
        children: <Widget>[
          AppText(
            text: '라이선스 전문·변경 내역 보기',
            style: AppTypography.label,
            color: AppColors.textLink,
          ),
          Gap(width: AppSpacing.xs),
          Icon(
            Icons.open_in_new_rounded,
            size: 14,
            color: AppColors.textLink,
          ),
        ],
      ),
    );
  }

  /// 사용한 오픈소스 고지
  Widget _buildOpenSourceSection() {
    return const AppInfoSection(
      title: '오픈소스',
      children: <Widget>[
        AppText(
          text: 'apple/ml-stable-diffusion',
          style: AppTypography.label,
          color: AppColors.textStrong,
        ),
        Gap(height: AppSpacing.xs),
        AppText(
          text: 'MIT License, Copyright © 2024 Apple Inc.',
          style: AppTypography.caption,
          color: AppColors.textSubtle,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}
