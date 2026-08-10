import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/song/hint.dart';
import 'package:picsong/domain/entities/song/lyric_line.dart';

/// 퀴즈 한 문제의 정답 곡.
class Song {
  /// 곡 식별자 (예: 'song_001')
  final String id;

  /// 곡 제목
  final String title;

  /// 가수
  final String artist;

  /// 곡이 속한 시대
  final Era era;

  /// 발매 연도
  final int year;

  /// 장르
  final String genre;

  /// 정답으로 인정하는 대체 표기(별칭·다른 읽기·흔한 오타)
  final List<String> acceptList;

  /// 이 곡 전용 그림 시드 — 없으면 `RoundService.imageSeed`(공용 고정 시드)를 쓴다
  ///
  /// 장면에는 이 값에 장면 순번을 더해 붙는다(첫 장 그대로, 둘째 장 +1 …).
  /// 공용 시드로 뽑은 그림이 마음에 안 드는 곡만 songs.json에 적어 덮어쓴다.
  final int? imageSeed;

  /// 이 곡 전용 힌트 목록 — 비어 있으면 가수 초성이 대신 나온다
  ///
  /// 힌트 시트의 발매연도·장르 행은 곡 메타에서 자동으로 붙으므로,
  /// 여기에는 그 두 행을 빼고 곡마다 다르게 줄 힌트만 적는다.
  final List<Hint> hintList;

  /// 클루로 출제 가능한 가사 라인 목록
  final List<LyricLine> lyricLineList;

  const Song({
    required this.title,
    required this.artist,
    required this.era,
    required this.year,
    required this.genre,
    this.id = '',
    this.acceptList = const <String>[],
    this.imageSeed,
    this.hintList = const <Hint>[],
    this.lyricLineList = const <LyricLine>[],
  });

  ///
  /// songs.json의 곡 한 건을 엔티티로 변환
  ///
  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        era: Era.fromQueryValue(json['era'] as String?),
        year: _parseYear(json['releaseDate']),
        genre: json['genre'] as String? ?? '',
        acceptList: _parseAcceptList(json['acceptList']),
        imageSeed: json['imageSeed'] is int ? json['imageSeed'] as int : null,
        hintList: _parseHintList(json['hints']),
        lyricLineList: _parseLyricLineList(json['lyricLines']),
      );

  /// 'YYYY.MM.DD' 형식에서 발매 연도만 파싱, 실패 시 0 (순수)
  static int _parseYear(Object? releaseDate) {
    if (releaseDate is! String) return 0;
    return int.tryParse(releaseDate.split('.').first) ?? 0;
  }

  /// 정답 대체 표기 목록 파싱 — 필드가 없으면 빈 목록 (순수)
  static List<String> _parseAcceptList(Object? raw) {
    if (raw is! List<Object?>) return const <String>[];
    return raw.whereType<String>().toList();
  }

  /// 곡별 힌트 목록 파싱 — 필드가 없으면 빈 목록 (순수)
  static List<Hint> _parseHintList(Object? raw) {
    if (raw is! List<Object?>) return const <Hint>[];
    return raw.whereType<Map<String, dynamic>>().map(Hint.fromJson).toList();
  }

  /// 가사 라인 목록 파싱 — 필드가 없으면 빈 목록 (순수)
  static List<LyricLine> _parseLyricLineList(Object? raw) {
    if (raw is! List<Object?>) return const <LyricLine>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(LyricLine.fromJson)
        .toList();
  }
}
