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
  /// 모든 클루에 쓰는 고정 시드 — 프롬프트 실험실과 같은 값이어야 한다
  ///
  /// 시드는 성패가 아니라 **구도**를 바꾼다. 곡 번호에서 시드를
  /// 파생하던 시절에는 실험실에서 채택한 그림과 게임에 나오는 그림이 서로 달랐다 —
  /// 프롬프트·프리픽스·스텝·guidance가 모두 같은데도 구도가 달라졌기 때문이다.
  /// 채택 판정이 실험실에서 내려지므로 게임도 같은 시드를 쓴다.
  ///
  /// **실험실이 이 상수를 직접 참조한다**(`PromptLabBatches._fixedSeed`).
  /// 두 곳이 같은 숫자를 따로 들고 있으면 언젠가 갈라진다.
  ///
  /// 이 시드로 뽑은 구도가 마음에 안 드는 곡은 songs.json에 `imageSeed`를
  /// 적어 곡 단위로 덮어쓴다 — `Song.imageSeed`.
  static const int imageSeed = 8888;

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
      sceneList: _toSceneList(song: song, lyricLine: lyricLine),
    );
  }

  /// 가사 줄의 프롬프트들을 시드가 붙은 장면 목록으로 변환 (순수)
  List<QuestionScene> _toSceneList({
    required Song song,
    required LyricLine lyricLine,
  }) {
    return lyricLine.imagePromptList.indexed
        .map(((int, String) entry) => QuestionScene(
              imagePrompt: entry.$2,
              imageSeed: _seedOf(song: song, sceneIndex: entry.$1),
            ))
        .toList();
  }

  /// 이 장면에 쓸 시드 — 곡 전용 시드가 있으면 장면 순번을 더해 쓴다 (순수)
  int _seedOf({required Song song, required int sceneIndex}) {
    final int? base = song.imageSeed;
    return base == null ? imageSeed : base + sceneIndex;
  }
}
