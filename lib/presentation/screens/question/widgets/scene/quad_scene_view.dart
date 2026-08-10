import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/double_scene_view.dart';

///
/// 한 가사 줄을 그림 네 장으로 표현하는 뷰
///
/// 두 장 구성을 위아래로 두 번 놓아 2×2로 만든다.
/// 두 줄 높이가 같아야 격자가 되므로 높이를 직접 정해 넘긴다.
/// 배지는 각 줄 안에만 둔다 — 두 줄 사이에도 넣으면 세로로 셋이 늘어선다.
///
class QuadSceneView extends StatelessWidget {
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

  const QuadSceneView({
    super.key,
    required this.imagePathList,
    required this.onSceneTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double rowHeight = _calculateRowHeight(constraints.maxWidth);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildRow(startIndex: 0, rowHeight: rowHeight),
            const Gap(height: AppSpacing.sm),
            _buildRow(startIndex: 2, rowHeight: rowHeight),
          ],
        );
      },
    );
  }

  /// 장면 두 칸이 나란히 놓인 한 줄
  Widget _buildRow({required int startIndex, required double rowHeight}) =>
      DoubleSceneView(
        imagePathList: imagePathList,
        onSceneTapped: onSceneTapped,
        startIndex: startIndex,
        rowHeight: rowHeight,
      );

  ///
  /// 화면 폭을 기준으로 행 높이를 사용 가능한 범위 안에 맞춘다
  ///
  double _calculateRowHeight(double maxWidth) {
    final double targetHeight = maxWidth * _heightRatio;
    return targetHeight.clamp(_minHeight, _maxHeight).toDouble();
  }
}
