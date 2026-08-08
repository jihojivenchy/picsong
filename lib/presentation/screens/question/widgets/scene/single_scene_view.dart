import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/scene_tile.dart';

///
/// 한 가사 줄을 그림 한 장으로 표현하는 뷰
///
/// 조합할 상대가 없으므로 묶음 액자를 두지 않고 그림 자체를 액자로 삼는다.
///
class SingleSceneView extends StatelessWidget {
  /// 그림 액자 높이
  static const double _height = 300;

  /// 장면별 이미지 경로 — 빈 문자열이면 생성 중
  final List<String> imagePathList;

  /// 그림을 눌렀을 때 — 크게 보기 요청
  final void Function(int index) onSceneTapped;

  const SingleSceneView({
    super.key,
    required this.imagePathList,
    required this.onSceneTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevationImage,
      ),
      child: SceneTile(
        imagePathList: imagePathList,
        index: 0,
        onTapped: onSceneTapped,
        borderRadius: AppRadius.xl,
      ),
    );
  }
}
