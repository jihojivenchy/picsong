import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/double_scene_view.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/scene_plus_badge.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/scene_tile.dart';

///
/// 한 가사 줄을 그림 세 장으로 표현하는 뷰
///
/// 두 장 구성을 그대로 윗줄로 쓰고 아래에 한 칸을 더 놓는다.
/// 두 줄 높이가 같아야 배지가 이음매 한가운데에 놓이므로 높이를 직접 정해 넘긴다.
///
class TripleSceneView extends StatelessWidget {
  /// 화면 폭 대비 행 높이 비율 — 두 줄이 되므로 두 장 구성보다 낮춘다
  static const double _heightRatio = 0.40;

  /// 행 최소 높이
  static const double _minHeight = 130;

  /// 행 최대 높이
  static const double _maxHeight = 160;

  /// 장면별 이미지 경로 — 빈 문자열이면 생성 중
  final List<String> imagePathList;

  /// 그림 한 칸을 눌렀을 때 — 크게 보기 요청
  final void Function(int index) onSceneTapped;

  const TripleSceneView({
    super.key,
    required this.imagePathList,
    required this.onSceneTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double rowHeight = _calculateRowHeight(constraints.maxWidth);
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DoubleSceneView(
                  imagePathList: imagePathList,
                  onSceneTapped: onSceneTapped,
                  rowHeight: rowHeight,
                ),
                const Gap(height: AppSpacing.sm),
                SizedBox(height: rowHeight, child: _buildLastTile()),
              ],
            ),
            const ScenePlusBadge(),
          ],
        );
      },
    );
  }

  /// 아랫줄을 가득 채우는 마지막 장면
  Widget _buildLastTile() => SceneTile(
        imagePathList: imagePathList,
        index: 2,
        onTapped: onSceneTapped,
      );

  ///
  /// 화면 폭을 기준으로 행 높이를 사용 가능한 범위 안에 맞춘다
  ///
  double _calculateRowHeight(double maxWidth) {
    final double targetHeight = maxWidth * _heightRatio;
    return targetHeight.clamp(_minHeight, _maxHeight).toDouble();
  }
}
