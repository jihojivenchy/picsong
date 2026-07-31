import 'dart:math';

import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/song/song.dart';

///
/// 라운드 구성 서비스
/// 시대의 곡 목록에서 한 라운드의 문제 목록을 만든다
///
class RoundService {
  ///
  /// 곡을 섞어 [count]개를 고르고, 곡마다 가사 한 줄을 뽑아 문제로 만든다
  ///
  /// 가사가 없는 곡은 그림을 그릴 수 없으므로 제외한다.
  /// [random]을 고정하면 같은 라운드가 재현된다.
  ///
  List<Question> buildRound({
    required List<Song> songList,
    required int count,
    required Random random,
  }) {
    final List<Song> candidateList = songList
        .where((Song song) => song.lyricLineList.isNotEmpty)
        .toList()
      ..shuffle(random);
    return candidateList
        .take(count)
        .map((Song song) => _toQuestion(song: song, random: random))
        .toList();
  }

  /// 곡에서 가사 한 줄을 무작위로 뽑아 문제로 만든다
  Question _toQuestion({required Song song, required Random random}) {
    final int lyricLineIndex = random.nextInt(song.lyricLineList.length);
    return Question(
      song: song,
      lyricLine: song.lyricLineList[lyricLineIndex],
      imageSeed: _imageSeedOf(song: song, lyricLineIndex: lyricLineIndex),
    );
  }

  /// 곡 식별자와 가사 위치로 그림 시드를 파생 (순수)
  int _imageSeedOf({required Song song, required int lyricLineIndex}) {
    final String digits = song.id.replaceAll(RegExp(r'\D'), '');
    return (int.tryParse(digits) ?? 0) * 100 + lyricLineIndex;
  }
}
