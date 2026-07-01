import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/image_paths.dart';

/// 별점 표시 위젯 (1~5점)
class StarRating extends StatelessWidget {
  /// 별점 (1~5)
  final int rating;

  /// 별 하나의 크기
  final double size;

  /// 별 사이 간격
  final double spacing;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: Image.asset(
            index < rating ? ImagePaths.starFilledReview : ImagePaths.starEmpty,
            width: size,
            height: size,
          ),
        );
      }),
    );
  }
}
