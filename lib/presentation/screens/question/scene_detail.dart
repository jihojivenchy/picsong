import 'package:picsong/presentation/router/router.dart';

///
/// 크게 볼 그림 목록과 시작 위치 — 아직 채워지지 않은 자리는 빼고 센다
///
ImageDetailArgs sceneDetailOf({
  required List<String> imagePathList,
  required int index,
}) =>
    (
      imagePathList:
          imagePathList.where((String path) => path.isNotEmpty).toList(),
      initialIndex: imagePathList
          .take(index)
          .where((String path) => path.isNotEmpty)
          .length,
    );
