import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/presentation/screens/reveal/reveal_screen.dart';

/// 힌트 시트에 표시할 항목(라벨-값 쌍).
typedef HintItem = ({String label, String value});

/// 퀴즈(문제 풀이) 화면 컨트롤러
class QuestionController extends GetxController {
  /// 한 라운드 문제 수
  static const int totalQuestions = 5;

  /// 한글 음절의 초성 테이블
  static const List<String> _choseongTable = <String>[
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', //
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  /// 진행 중인 시대
  final Era era;

  /// 진행 중인 시대의 문제(곡) 목록
  late final List<Song> _songs;

  /// 현재 문제 인덱스 (0-based)
  final RxInt qIndex = 0.obs;

  /// 현재 문제의 힌트 사용 여부 (문제당 1회)
  final RxBool hintUsed = false.obs;

  QuestionController({required this.era});

  /// 문제 목록 적재
  @override
  void onInit() {
    super.onInit();
    _songs = Song.mockListOf(era);
  }

  /// 현재 문제의 정답 곡
  Song get currentSong => _songs[qIndex.value];

  /// 현재 곡의 힌트 항목(가수 초성 / 발매연도 / 장르)
  List<HintItem> get currentHints => _buildHints(currentSong);

  /// 마지막 문제 여부
  bool get _isLastQuestion => qIndex.value >= totalQuestions - 1;

  ///
  /// 힌트 사용 처리 — 문제당 1회만 허용
  ///
  void useHint() {
    if (hintUsed.value) return;
    hintUsed.value = true;
  }

  ///
  /// 정답 제출 — 정답이면 공개 화면으로 이동, 오답이면 false 반환(화면 유지)
  ///
  bool submit(String guess) {
    final bool isCorrect = currentSong.matches(guess);
    if (isCorrect) _goToReveal(isCorrect: true);
    return isCorrect;
  }

  ///
  /// 답안 공개 — 정답 공개 화면으로 이동(포기)
  ///
  void revealAnswer() => _goToReveal(isCorrect: false);

  ///
  /// 다음 단계 진행 — 마지막이면 홈 복귀, 아니면 다음 문제
  ///
  void goToNext() {
    if (_isLastQuestion) {
      // TODO: ResultScreen 구현 시 결과 화면으로 교체
      Get.until((Route<dynamic> route) => route.isFirst);
      return;
    }
    qIndex.value++;
    hintUsed.value = false;
    Get.back();
  }

  /// 정답 공개 화면으로 이동 (정답/포기 공통)
  void _goToReveal({required bool isCorrect}) {
    Get.to(
      () => RevealScreen(
        era: era,
        song: currentSong,
        isCorrect: isCorrect,
        isLast: _isLastQuestion,
        onNext: goToNext,
      ),
    );
  }

  /// 곡 메타를 힌트 항목 목록으로 변환 (순수)
  List<HintItem> _buildHints(Song song) => <HintItem>[
        (label: '가수 초성', value: _toChoseong(song.artist)),
        (label: '발매연도', value: '${song.year}년'),
        (label: '장르', value: song.genre),
      ];

  /// 문자열의 한글 음절을 초성으로 변환, 그 외 문자는 그대로 (순수)
  String _toChoseong(String text) => text.runes.map(_choseongOf).join();

  /// 코드포인트 1개를 초성으로 변환 (한글 음절이 아니면 원문 유지) (순수)
  String _choseongOf(int code) {
    const int base = 0xAC00;
    const int last = 0xD7A3;
    if (code < base || code > last) return String.fromCharCode(code);
    return _choseongTable[(code - base) ~/ 588];
  }
}
