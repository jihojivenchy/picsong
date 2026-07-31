import 'package:picsong/domain/entities/era/era.dart';
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

  /// 가사 라인 목록 파싱 — 필드가 없으면 빈 목록 (순수)
  static List<LyricLine> _parseLyricLineList(Object? raw) {
    if (raw is! List<Object?>) return const <LyricLine>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(LyricLine.fromJson)
        .toList();
  }
}
