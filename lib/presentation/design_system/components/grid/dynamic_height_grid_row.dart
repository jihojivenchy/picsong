import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';

class DynamicHeightGridRow extends StatelessWidget {
  const DynamicHeightGridRow({
    super.key,
    required this.columnIndex,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.crossAxisAlignment,
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
  final CrossAxisAlignment crossAxisAlignment;

  /// 행의 인덱스
  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: (columnIndex == 0) ? 0 : mainAxisSpacing, // 첫 행을 제외하고 간격 적용
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: List.generate(
          (crossAxisCount * 2) - 1, // 아이템 간 간격을 포함하기 위해 2n - 1 개로 계산
          (rowIndex) {
            final rowNum = rowIndex + 1;

            // 짝수 인덱스는 간격용 SizedBox
            if (rowNum % 2 == 0) {
              return Gap(width: crossAxisSpacing);
            }

            // 해당 row 아이템 인덱스가 실제 데이터 리스트에서 몇 번째 인덱스인지 계산
            final rowItemIndex = ((rowNum + 1) ~/ 2) - 1;
            final itemIndex = (columnIndex * crossAxisCount) + rowItemIndex;

            // 해당 row 아이템 인덱스가 데이터 리스트의 범위를 넘어가면 빈 위젯 반환
            if (itemIndex > itemCount - 1) {
              return const Expanded(child: SizedBox());
            }

            // 홀수 인덱스는 아이템 반영
            return Expanded(
              child: builder(context, itemIndex),
            );
          },
        ),
      ),
    );
  }
}
