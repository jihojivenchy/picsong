import 'dart:math';

import 'package:picsong/domain/entities/song/song.dart';

///
/// 채점 서비스
/// 사용자가 입력한 답이 정답 곡으로 인정되는지 판정
///
class ScoringService {
  ///
  /// 입력이 곡의 정답으로 인정되는지 판정 — 공백·문장부호 무시 + 가벼운 오타 허용
  ///
  bool isCorrect({required Song song, required String guess}) {
    final String normalized = _normalize(guess);
    if (normalized.isEmpty) return false;
    final List<String> targetList =
        <String>[song.title, ...song.acceptList].map(_normalize).toList();
    return targetList.any((String target) => _isClose(normalized, target));
  }

  /// 두 정규화 문자열이 동일하거나 허용 오차 내인지 (순수)
  bool _isClose(String guess, String target) {
    if (target.isEmpty) return false;
    if (guess == target) return true;
    final int tolerance = target.length <= 4 ? 1 : 2;
    return _levenshtein(guess, target) <= tolerance;
  }

  /// 비교용 정규화 — 소문자화 + 공백/문장부호 제거 (순수)
  String _normalize(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'''[\s.\-_'"!?·]'''), '');

  /// 두 문자열의 편집 거리(Levenshtein) (순수)
  int _levenshtein(String a, String b) {
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
}
