import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/domain/services/scoring/scoring_service.dart';
import 'package:picsong/presentation/screens/question/result/question_result_screen.dart';
import 'package:picsong/utils/services/app_logger.dart';

/// 힌트 시트에 표시할 항목(라벨-값 쌍).
typedef HintItem = ({String label, String value});

/// 퀴즈(문제 풀이) 화면 컨트롤러
class QuestionController extends GetxController {
  /// 한글 음절의 초성 테이블
  static const List<String> _choseongTable = <String>[
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', //
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  /// 진행 중인 시대
  final Era era;

  /// 이번 라운드의 문제 목록
  final List<Question> questionList;

  /// 로딩 화면에서 미리 생성해둔 1번 문제 이미지 경로
  final String firstImagePath;

  QuestionController({
    required this.era,
    required this.questionList,
    required this.firstImagePath,
  });

  /// 온디바이스 클루 이미지 생성 서비스
  final ClueService _clueService = ClueService();

  /// 채점 서비스
  final ScoringService _scoringService = ScoringService();

  /// 오답 안내를 트리거하는 변경 신호
  final RxInt wrongAnswerSignal = 0.obs;

  /// 사용자가 입력한 답안
  final TextEditingController textController = TextEditingController();

  /// 현재 문제 인덱스 (0-based)
  final RxInt qIndex = 0.obs;

  /// 현재 문제의 힌트 사용 여부 (문제당 1회)
  final RxBool hintUsed = false.obs;

  /// 현재 문제의 클루 이미지 경로 — 비어 있으면 생성 대기
  final RxString clueImagePath = ''.obs;

  /// 현재 문제
  Question get currentQuestion => questionList[qIndex.value];

  /// 현재 곡의 힌트 항목(가수 초성 / 발매연도 / 장르)
  List<HintItem> get currentHints => _buildHints(currentQuestion.song);

  /// 마지막 문제 여부
  bool get _isLastQuestion => qIndex.value >= questionList.length - 1;

  @override
  void onInit() {
    super.onInit();
    // 첫 이미지 반영
    clueImagePath.value = firstImagePath;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  ///
  /// 힌트 사용 처리 — 문제당 1회만 허용
  ///
  void useHint() {
    if (hintUsed.value) return;
    hintUsed.value = true;
  }

  ///
  /// 정답 제출 — 정답이면 결과 화면으로 이동, 오답이면 안내를 표시
  ///
  void submit(String guess) {
    final String normalizedGuess = guess.trim();
    if (normalizedGuess.isEmpty) return;
    final bool isCorrect = _scoringService.isCorrect(
      song: currentQuestion.song,
      guess: normalizedGuess,
    );
    if (!isCorrect) {
      _notifyWrongAnswer();
      return;
    }
    _goToQuestionResult(isCorrect: true);
  }

  ///
  /// 답안 공개 — 문제 결과 화면으로 이동
  ///
  void revealAnswer() => _goToQuestionResult(isCorrect: false);

  ///
  /// 다음 단계 진행 — 마지막이면 홈 복귀, 아니면 다음 문제
  ///
  void goToNext() {
    if (_isLastQuestion) {
      // TODO: RoundResultScreen 구현 시 라운드 결과 화면으로 교체
      Get.until((Route<dynamic> route) => route.isFirst);
      return;
    }

    // 다음 문제로 이동
    qIndex.value++;

    // 힌트 사용 여부 초기화
    hintUsed.value = false;

    // 다음 문제의 이미지 생성
    _generateClueImage();

    // 텍스트 필드 초기화
    textController.clear();

    // 이전 화면으로 이동
    Get.back();
  }

  ///
  /// 현재 문제의 클루 이미지를 온디바이스로 생성해 상태에 반영
  ///
  Future<void> _generateClueImage() async {
    // 이미지 경로 초기화
    clueImagePath.value = '';

    // 현재 문제 정보 조회
    final Question question = currentQuestion;

    try {
      // 이미지 생성 요청
      clueImagePath.value = await _clueService.generateClueImage(
        scene: question.lyricLine.imagePrompt,
        seed: question.imageSeed,
      );
    } catch (error) {
      AppLogger.error('클루 이미지 생성 실패', error: error);
    }
  }

  ///
  /// 문제 결과 화면으로 이동
  ///
  void _goToQuestionResult({required bool isCorrect}) {
    Get.to(
      () => QuestionResultScreen(
        era: era,
        question: currentQuestion,
        imagePath: clueImagePath.value,
        isCorrect: isCorrect,
        isLast: _isLastQuestion,
        onNext: goToNext,
      ),
    );
  }

  ///
  /// 오답 안내가 필요한 제출 이벤트를 화면에 알린다
  ///
  void _notifyWrongAnswer() => wrongAnswerSignal.value += 1;

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
