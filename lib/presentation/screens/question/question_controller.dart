import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/question/question_result.dart';
import 'package:picsong/domain/entities/question/question_scene.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/domain/services/scoring/scoring_service.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/screens/image_detail/image_detail_screen.dart';
import 'package:picsong/presentation/screens/question/result/question_result_screen.dart';
import 'package:picsong/presentation/screens/round_result/round_result_screen.dart';
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

  /// 지금까지 푼 문제의 결과
  final List<QuestionResult> _resultList = <QuestionResult>[];

  /// 오답 안내를 트리거하는 변경 신호
  final RxInt wrongAnswerSignal = 0.obs;

  /// 사용자가 입력한 답안
  final TextEditingController textController = TextEditingController();

  /// 현재 문제 인덱스 (0-based)
  final RxInt qIndex = 0.obs;

  /// 지금까지 공개된 클루 이미지 경로 목록 — 마지막 항목이 빈 문자열이면 생성 중
  final RxList<String> clueImagePathList = <String>[].obs;

  /// 현재 문제의 장면을 아직 그리는 중인지 — 다 그려지기 전에는 답안 공개를 막는다
  final RxBool isGeneratingScenes = false.obs;

  /// 현재 문제
  Question get currentQuestion => questionList[qIndex.value];

  /// 현재 곡의 힌트 항목(가수 초성 / 발매연도 / 장르)
  List<HintItem> get currentHints => _buildHints(currentQuestion.song);

  /// 마지막 문제 여부
  bool get _isLastQuestion => qIndex.value >= questionList.length - 1;

  @override
  void onInit() {
    super.onInit();
    // 로딩 화면이 첫 장면을 미리 뽑아뒀다. 나머지 장면을 이어서 채운다
    _generateScenes(firstImagePath: firstImagePath);
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
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
  /// 답안 공개 — 그림이 다 그려진 뒤에만 연다
  ///
  /// 결과 화면은 그림 목록을 스냅샷으로 받으므로, 그리는 중에 열면
  /// 못 채운 칸이 그대로 남는다.
  ///
  void revealAnswer() {
    if (isGeneratingScenes.value) {
      AppToastService.show('그림을 아직 그리고 있어요');
      return;
    }
    _goToQuestionResult(isCorrect: false);
  }

  ///
  /// 클루 그림 크게 보기 — 아직 채워지지 않은 자리는 빼고 넘긴다
  ///
  void openSceneDetail(int index) {
    final List<String> scenePathList = clueImagePathList.toList();
    final List<String> revealedPathList =
        scenePathList.where((String path) => path.isNotEmpty).toList();
    final int initialIndex = scenePathList
        .take(index)
        .where((String path) => path.isNotEmpty)
        .length;
    Get.to(
      () => ImageDetailScreen(
        imagePathList: revealedPathList,
        initialIndex: initialIndex,
      ),
      opaque: false,
      // 뒤 화면이 비치는 라우트라 뒤 화면이 밀려나면 안 된다.
      // fullscreenDialog는 canTransitionTo를 막아 뒤 화면의 퇴장 애니메이션을 끈다.
      fullscreenDialog: true,
      transition: Transition.fadeIn,
      duration: AppMotion.durationBase,
    );
  }

  ///
  /// 다음 단계 진행 — 마지막이면 라운드 결과, 아니면 다음 문제
  ///
  void goToNext() {
    if (_isLastQuestion) {
      Get.off(
        () => RoundResultScreen(
          era: era,
          resultList: List<QuestionResult>.unmodifiable(_resultList),
        ),
      );
      return;
    }

    // 다음 문제로 이동
    qIndex.value++;

    // 다음 문제의 장면 전부 생성
    _generateScenes();

    // 텍스트 필드 초기화
    textController.clear();

    // 이전 화면으로 이동
    Get.back();
  }

  ///
  /// 현재 문제의 클루 장면을 앞에서부터 순서대로 생성해 채운다
  ///
  /// [firstImagePath]가 있으면 첫 장면은 그것을 쓰고 둘째 장면부터 생성한다.
  /// 생성 전 자리는 빈 문자열이며, 화면은 이를 로딩으로 표시한다.
  ///
  Future<void> _generateScenes({String firstImagePath = ''}) async {
    final List<QuestionScene> sceneList = currentQuestion.sceneList;
    isGeneratingScenes.value = true;
    clueImagePathList.assignAll(
      List<String>.filled(sceneList.length, '')..[0] = firstImagePath,
    );
    for (int index = 0; index < sceneList.length; index++) {
      if (clueImagePathList[index].isNotEmpty) continue;
      clueImagePathList[index] = await _generateScene(sceneList[index]);
    }
    isGeneratingScenes.value = false;
  }

  /// 장면 하나를 생성해 파일 경로를 반환, 실패하면 빈 문자열
  Future<String> _generateScene(QuestionScene scene) async {
    try {
      return await _clueService.generateClueImage(
        scene: scene.imagePrompt,
        seed: scene.imageSeed,
      );
    } catch (error) {
      AppLogger.error('클루 이미지 생성 실패', error: error);
      return '';
    }
  }

  ///
  /// 문제 결과를 라운드에 기록
  ///
  void _recordResult({required bool isCorrect}) {
    _resultList.add(
      QuestionResult(
        question: currentQuestion,
        isCorrect: isCorrect,
      ),
    );
  }

  ///
  /// 문제 결과 화면으로 이동
  ///
  void _goToQuestionResult({required bool isCorrect}) {
    _recordResult(isCorrect: isCorrect);
    Get.to(
      () => QuestionResultScreen(
        era: era,
        question: currentQuestion,
        imagePathList: clueImagePathList.toList(),
        onSceneTapped: openSceneDetail,
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
