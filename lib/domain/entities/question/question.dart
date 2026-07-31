import 'package:picsong/domain/entities/song/lyric_line.dart';
import 'package:picsong/domain/entities/song/song.dart';

/// 라운드의 한 문제 — 정답 곡과 그 곡에서 출제된 가사 한 줄.
class Question {
  /// 정답 곡
  final Song song;

  /// 이 문제로 출제된 가사 라인
  final LyricLine lyricLine;

  /// 클루 이미지 생성 시드 — 같은 곡·같은 가사면 항상 같은 그림
  final int imageSeed;

  const Question({
    required this.song,
    required this.lyricLine,
    required this.imageSeed,
  });
}
