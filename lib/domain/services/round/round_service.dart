import 'dart:math';

import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/question/question_scene.dart';
import 'package:picsong/domain/entities/song/lyric_line.dart';
import 'package:picsong/domain/entities/song/song.dart';

///
/// 라운드 구성 서비스
/// 시대의 곡 목록에서 한 라운드의 문제 목록을 만든다
///
class RoundService {
  ///
  /// 곡을 섞어 [count]개를 고르고, 곡마다 가사 한 줄을 뽑아 문제로 만든다
  ///
  /// 그림을 만들 수 없는 곡(가사가 없거나 프롬프트가 없는 곡)은 제외한다.
  /// [random]을 고정하면 같은 라운드가 재현된다.
  ///
  List<Question> buildRound({
    required List<Song> songList,
    required int count,
    required Random random,
  }) {
    final List<Song> candidateList = songList.where(_isPlayable).toList()
      ..shuffle(random);
    return candidateList
        .take(count)
        .map((Song song) => _toQuestion(song: song, random: random))
        .toList();
  }

  /// 그림으로 낼 수 있는 가사가 하나라도 있는 곡인지 (순수)
  bool _isPlayable(Song song) => song.lyricLineList
      .any((LyricLine line) => line.imagePromptList.isNotEmpty);

  /// 곡에서 가사 한 줄을 무작위로 뽑아 문제로 만든다
  Question _toQuestion({required Song song, required Random random}) {
    final List<LyricLine> playableList = song.lyricLineList
        .where((LyricLine line) => line.imagePromptList.isNotEmpty)
        .toList();
    final int lineIndex = random.nextInt(playableList.length);
    final LyricLine lyricLine = playableList[lineIndex];
    return Question(
      song: song,
      lyricLine: lyricLine,
      sceneList: _toSceneList(
        song: song,
        lyricLine: lyricLine,
        lineIndex: lineIndex,
      ),
    );
  }

  /// 가사 줄의 프롬프트들을 시드가 붙은 장면 목록으로 변환 (순수)
  List<QuestionScene> _toSceneList({
    required Song song,
    required LyricLine lyricLine,
    required int lineIndex,
  }) {
    return lyricLine.imagePromptList.indexed.map(((int, String) entry) {
      final (int sceneIndex, String imagePrompt) = entry;
      return QuestionScene(
        imagePrompt: imagePrompt,
        imageSeed: _imageSeedOf(
          song: song,
          lineIndex: lineIndex,
          sceneIndex: sceneIndex,
        ),
      );
    }).toList();
  }

  /// 곡 식별자·가사 위치·장면 위치로 그림 시드를 파생 (순수)
  int _imageSeedOf({
    required Song song,
    required int lineIndex,
    required int sceneIndex,
  }) {
    final String digits = song.id.replaceAll(RegExp(r'\D'), '');
    final int songNumber = int.tryParse(digits) ?? 0;
    return songNumber * 1000 + lineIndex * 10 + sceneIndex;
  }
}
