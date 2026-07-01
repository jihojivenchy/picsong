import 'dart:math';

import 'package:picsong/domain/entities/era/era.dart';

/// 퀴즈 한 문제의 정답 곡.
class Song {
  /// 곡 제목
  final String title;

  /// 가수
  final String artist;

  /// 발매 연도
  final int year;

  /// 장르
  final String genre;

  /// 정답으로 인정하는 대체 표기(별칭·다른 읽기·흔한 오타)
  final List<String> acceptList;

  const Song({
    required this.title,
    required this.artist,
    required this.year,
    required this.genre,
    this.acceptList = const <String>[],
  });

  /// 입력이 정답과 일치하는지 — 공백·문장부호 무시 + 가벼운 오타 허용 (순수)
  bool matches(String guess) {
    final String normalized = _normalize(guess);
    if (normalized.isEmpty) return false;
    final List<String> targets =
        <String>[title, ...acceptList].map(_normalize).toList();
    return targets.any((String target) => _isClose(normalized, target));
  }

  /// 해당 시대의 목 곡 목록 반환.
  static List<Song> mockListOf(Era era) => _mockByEra[era] ?? const <Song>[];

  /// 두 정규화 문자열이 동일하거나 허용 오차 내인지 (순수)
  bool _isClose(String guess, String target) {
    if (target.isEmpty) return false;
    if (guess == target) return true;
    final int tolerance = target.length <= 4 ? 1 : 2;
    return _levenshtein(guess, target) <= tolerance;
  }

  /// 비교용 정규화 — 소문자화 + 공백/문장부호 제거 (순수)
  static String _normalize(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'''[\s.\-_'"!?·]'''), '');

  /// 두 문자열의 편집 거리(Levenshtein) (순수)
  static int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    List<int> previous = List<int>.generate(b.length + 1, (int j) => j);
    for (int i = 1; i <= a.length; i++) {
      final List<int> current = List<int>.filled(b.length + 1, 0);
      current[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = <int>[
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + cost,
        ].reduce(min);
      }
      previous = current;
    }
    return previous[b.length];
  }

  /// 시대별 목 곡 데이터 (시대당 5문제). 백엔드 없이 로컬에서만 사용.
  static const Map<Era, List<Song>> _mockByEra = <Era, List<Song>>{
    Era.era80s: <Song>[
      Song(title: '광화문 연가', artist: '이문세', year: 1988, genre: '발라드', acceptList: <String>['광화문연가']),
      Song(title: '친구여', artist: '조용필', year: 1983, genre: '발라드', acceptList: <String>['친구여']),
      Song(title: '그것만이 내 세상', artist: '들국화', year: 1985, genre: '록', acceptList: <String>['그것만이내세상']),
      Song(title: '잊혀진 계절', artist: '이용', year: 1982, genre: '발라드', acceptList: <String>['잊혀진계절', '잊혀진게절']),
      Song(title: '청춘', artist: '산울림', year: 1981, genre: '포크록', acceptList: <String>['청춘']),
    ],
    Era.era90s: <Song>[
      Song(title: '난 알아요', artist: '서태지와 아이들', year: 1992, genre: '댄스', acceptList: <String>['난알아요']),
      Song(title: '잘못된 만남', artist: '김건모', year: 1995, genre: '댄스', acceptList: <String>['잘못된만남']),
      Song(title: '달팽이', artist: '패닉', year: 1995, genre: '발라드', acceptList: <String>['달팽이']),
      Song(title: '보이지 않는 사랑', artist: '신승훈', year: 1991, genre: '발라드', acceptList: <String>['보이지않는사랑']),
      Song(title: '아주 오래된 연인들', artist: '015B', year: 1992, genre: '발라드', acceptList: <String>['아주오래된연인들']),
    ],
    Era.era00s: <Song>[
      Song(title: '벚꽃 엔딩', artist: '버스커 버스커', year: 2012, genre: '인디', acceptList: <String>['벚꽃엔딩', '벗꽃엔딩']),
      Song(title: '체념', artist: '빅마마', year: 2003, genre: 'R&B', acceptList: <String>['체념']),
      Song(title: '10 Minutes', artist: '이효리', year: 2003, genre: '댄스', acceptList: <String>['10minutes', '텐미닛', '10미닛']),
      Song(title: '벌써 일년', artist: '브라운 아이즈', year: 2001, genre: 'R&B', acceptList: <String>['벌써일년']),
      Song(title: '라라라', artist: 'SG워너비', year: 2006, genre: '발라드', acceptList: <String>['라라라']),
    ],
    Era.era10s: <Song>[
      Song(title: '벚꽃 엔딩', artist: '버스커 버스커', year: 2012, genre: '인디', acceptList: <String>['벚꽃엔딩', '벗꽃엔딩']),
      Song(title: '좋은 날', artist: '아이유', year: 2010, genre: '댄스팝', acceptList: <String>['좋은날']),
      Song(title: '강남스타일', artist: '싸이', year: 2012, genre: '댄스', acceptList: <String>['강남스타일', 'gangnamstyle']),
      Song(title: '우주를 줄게', artist: '볼빨간사춘기', year: 2017, genre: '인디팝', acceptList: <String>['우주를줄게']),
      Song(title: 'TT', artist: '트와이스', year: 2016, genre: '댄스팝', acceptList: <String>['tt', '티티']),
    ],
    Era.era20s: <Song>[
      Song(title: 'Ditto', artist: '뉴진스', year: 2022, genre: '팝', acceptList: <String>['ditto', '디토']),
      Song(title: 'LOVE DIVE', artist: '아이브', year: 2022, genre: '댄스팝', acceptList: <String>['lovedive', '러브다이브']),
      Song(title: 'Dynamite', artist: '방탄소년단', year: 2020, genre: '디스코팝', acceptList: <String>['dynamite', '다이너마이트']),
      Song(title: '라일락', artist: '아이유', year: 2021, genre: '팝', acceptList: <String>['라일락']),
      Song(title: 'TOMBOY', artist: '(여자)아이들', year: 2022, genre: '록팝', acceptList: <String>['tomboy', '톰보이']),
    ],
  };
}
