import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/song/scene_count.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/double_scene_view.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/single_scene_view.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/triple_scene_view.dart';

///
/// 한 가사 줄을 그림 1~3장으로 표현하는 뷰
///
/// 장수마다 배치가 달라 뷰를 따로 두고, 여기서는 고르기만 한다.
/// 여러 장일 때만 그림들을 하나로 묶는 액자를 씌운다.
///
class QuestionSceneView extends StatelessWidget {
  /// 이 문제의 그림 장수
  final SceneCount sceneCount;

  /// 장면별 이미지 경로 — 빈 문자열이면 생성 중
  final List<String> imagePathList;

  /// 그림 한 칸을 눌렀을 때 — 크게 보기 요청
  final void Function(int index) onSceneTapped;

  const QuestionSceneView({
    super.key,
    required this.sceneCount,
    required this.imagePathList,
    required this.onSceneTapped,
  });

  @override
  Widget build(BuildContext context) {
    return switch (sceneCount) {
      SceneCount.one => SingleSceneView(
          imagePathList: imagePathList,
          onSceneTapped: onSceneTapped,
        ),
      SceneCount.two => _buildFrame(
          DoubleSceneView(
            imagePathList: imagePathList,
            onSceneTapped: onSceneTapped,
          ),
        ),
      SceneCount.three => _buildFrame(
          TripleSceneView(
            imagePathList: imagePathList,
            onSceneTapped: onSceneTapped,
          ),
        ),
    };
  }

  ///
  /// 그림들이 한 문제라는 것을 드러내는 묶음 액자
  ///
  Widget _buildFrame(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.elevationImage,
      ),
      child: child,
    );
  }
}
