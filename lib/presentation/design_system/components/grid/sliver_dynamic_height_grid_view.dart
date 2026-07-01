
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/grid/dynamic_height_grid_row.dart';

/// CustomScrollView에서 사용 가능한 Sliver 버전의 DynamicHeightGridView
class SliverDynamicHeightGridView extends StatelessWidget {
  const SliverDynamicHeightGridView({
    super.key,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
  });

  /// 아이템을 그릴 빌더 함수
  final IndexedWidgetBuilder builder;

  /// 총 아이템 개수
  final int itemCount;

  /// 가로에 배치될 아이템 수
  final int crossAxisCount;

  /// 가로 간격
  final double crossAxisSpacing;

  /// 세로 간격
  final double mainAxisSpacing;

  /// Row 위젯의 CrossAxisAlignment (세로 정렬)
  final CrossAxisAlignment rowCrossAxisAlignment;

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: columnLength(),
        (ctx, columnIndex) {
          return DynamicHeightGridRow(
            columnIndex: columnIndex,
            builder: builder,
            itemCount: itemCount,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisAlignment: rowCrossAxisAlignment,
          );
        },
      ),
    );
  }

  /// 행(Row)의 개수 계산
  int columnLength() {
    // 행의 갯수가 전체 아이템 갯수와 나누어 떨어지면 그대로 반환
    if ((itemCount % crossAxisCount) == 0) {
      return itemCount ~/ crossAxisCount;
    } else {
      // 나누어 떨어지지 않으면 1을 더해서 반환
      return (itemCount ~/ crossAxisCount) + 1;
    }
  }
}
