
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/grid/dynamic_height_grid_row.dart';


/// 각 아이템의 높이에 따라 동적으로 행의 높이가 설정되는 그리드 뷰입니다.
class DynamicHeightGridView extends StatelessWidget {
  const DynamicHeightGridView({
    super.key,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
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
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: columnLength(), // 전체 행 수만큼 생성
      itemBuilder: (context, columnIndex) {
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
      
    );
  }

  /// 행(Row)의 개수 계산
  int columnLength() {
    // 행의 갯수가 전체 아이템 갯수와 나누어 떨어지면 그대로 반환
    if ((itemCount % crossAxisCount) == 0) {
      return itemCount ~/ crossAxisCount;
    } else {
      
      return (itemCount ~/ crossAxisCount) + 1;
    }
  }
}
