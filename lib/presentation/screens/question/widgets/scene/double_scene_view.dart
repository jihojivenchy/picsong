import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/scene_plus_badge.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/scene_tile.dart';

///
/// 한 가사 줄을 그림 두 장으로 표현하는 뷰
///
/// 세 장 구성의 윗줄로도 쓰인다. 그때는 아랫줄과 높이를 맞춰야 하므로
/// [rowHeight]를 받아 스스로 계산하지 않는다.
///
class DoubleSceneView extends StatelessWidget {
  /// 화면 폭 대비 행 높이 비율
  static const double _heightRatio = 0.62;

  /// 행 최소 높이
  static const double _minHeight = 180;

  /// 행 최대 높이
  static const double _maxHeight = 220;

  /// 장면별 이미지 경로 — 빈 문자열이면 생성 중
  final List<String> imagePathList;

  /// 그림 한 칸을 눌렀을 때 — 크게 보기 요청
  final void Function(int index) onSceneTapped;

  /// 행 높이 — 지정하지 않으면 폭에 맞춰 스스로 정한다
  final double? rowHeight;

  const DoubleSceneView({
    super.key,
    required this.imagePathList,
    required this.onSceneTapped,
    this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: rowHeight ?? _calculateRowHeight(constraints.maxWidth),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _buildTile(0)),
                  const Gap(width: AppSpacing.sm),
                  Expanded(child: _buildTile(1)),
                ],
              ),
              const ScenePlusBadge(),
            ],
          ),
        );
      },
    );
  }

  /// 장면 한 칸
  Widget _buildTile(int index) => SceneTile(
        imagePathList: imagePathList,
        index: index,
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
