import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/screens/question/widgets/scene/question_image.dart';

///
/// 부모가 내어준 칸을 그대로 채우는 클루 그림 한 칸
///
/// 아직 그려지지 않은 자리는 대기로만 표시하고 탭을 받지 않는다.
///
class SceneTile extends StatelessWidget {
  /// 장면별 이미지 경로 — 빈 문자열이면 생성 중
  final List<String> imagePathList;

  /// 이 칸이 맡은 장면 위치
  final int index;

  /// 그림을 눌렀을 때 — 크게 보기 요청
  final void Function(int index) onTapped;

  /// 모서리 둥글기 — 한 장짜리 문제는 더 크게 쓴다
  final double borderRadius;

  const SceneTile({
    super.key,
    required this.imagePathList,
    required this.index,
    required this.onTapped,
    this.borderRadius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = _resolveImagePath();
    final Widget scene = SizedBox.expand(
      child: QuestionImage(imageURL: imagePath, borderRadius: borderRadius),
    );
    if (imagePath.isEmpty) return scene;
    return GestureDetector(
      onTap: () => onTapped(index),
      child: scene,
    );
  }

  /// 아직 채워지지 않은 자리를 빈 경로로 돌려준다 (순수)
  String _resolveImagePath() =>
      index < imagePathList.length ? imagePathList[index] : '';
}
