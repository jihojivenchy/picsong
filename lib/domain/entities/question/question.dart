import 'package:picsong/domain/entities/question/question_scene.dart';
import 'package:picsong/domain/entities/song/lyric_line.dart';
import 'package:picsong/domain/entities/song/song.dart';

/// 라운드의 한 문제 — 정답 곡과 출제된 가사 한 줄, 그리고 그 줄을 쪼갠 장면들.
///
/// 한 장에는 요소 하나만 담기므로 가사 한 줄을 여러 장으로 나눠
/// **동시에** 보여준다. 플레이어가 그림들을 조합해 가사를 유추한다.
class Question {
  /// 정답 곡
  final Song song;

  /// 이 문제로 출제된 가사 라인
  final LyricLine lyricLine;

  /// 함께 보여줄 클루 장면 목록 — 표시 순서대로
  final List<QuestionScene> sceneList;

  const Question({
    required this.song,
    required this.lyricLine,
    required this.sceneList,
  });

  /// 첫 장면 — 로딩 화면이 미리 생성해두는 대상
  QuestionScene get firstScene => sceneList.first;
}
