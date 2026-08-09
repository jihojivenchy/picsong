import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/question/question_result.dart';
import 'package:picsong/domain/entities/question/question_scene.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/domain/services/scoring/scoring_service.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/utils/services/app_logger.dart';

part 'question_state.dart';

/// 힌트 시트에 표시할 항목
typedef HintItem = ({String label, String value});

/// 퀴즈(문제 풀이) 화면 뷰모델
class QuestionCubit extends Cubit<QuestionState> {
  /// 이번 라운드의 문제 목록
  final List<Question> questionList;
  QuestionCubit({required this.questionList}) : super(const QuestionState());

  /// 한글 음절의 초성 테이블
  static const List<String> _choseongTable = <String>[
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', //
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  /// 온디바이스 클루 이미지 생성 서비스
  final ClueService _clueService = ClueService();

  /// 채점 서비스
  final ScoringService _scoringService = ScoringService();

  /// 지금까지 푼 문제의 결과
  final List<QuestionResult> _resultList = <QuestionResult>[];

  /// 사용자가 입력한 답안
  final TextEditingController textController = TextEditingController();

  /// 현재 문제
  Question get currentQuestion => questionList[state.qIndex];

  /// 현재 곡의 힌트 항목
  List<HintItem> get currentHints => _buildHints(currentQuestion.song);

  /// 마지막 문제 여부
  bool get isLastQuestion => state.qIndex >= questionList.length - 1;

  /// 지금까지 푼 문제의 결과 (출제 순서)
  List<QuestionResult> get resultList =>
      List<QuestionResult>.unmodifiable(_resultList);

  @override
  Future<void> close() {
    textController.dispose();
    return super.close();
  }

  ///
  /// 현재 문제의 클루 장면을 앞에서부터 순서대로 생성해 채운다
  ///
  /// [firstImagePath]가 있으면 첫 장면은 그것을 쓰고 둘째 장면부터 생성한다.
  /// 생성 전 자리는 빈 문자열이며, 화면은 이를 로딩으로 표시한다.
  ///
  Future<void> generateScenes({String firstImagePath = ''}) async {
    // 현재 문제의 그림 목록 조회
    final List<QuestionScene> sceneList = currentQuestion.sceneList;

    // 그림 목록 초기화
    emit(
      state.copyWith(
        clueImagePathList: _initialPathList(
          sceneCount: sceneList.length,
          firstImagePath: firstImagePath,
        ),
        isGeneratingScenes: true,
      ),
    );

    // 그림 목록 생성
    for (int index = 0; index < sceneList.length; index++) {
      // 그림을 이미 생성했으면 건너뛰기
      if (state.clueImagePathList[index].isNotEmpty) continue;

      // 그림 생성
      final String imagePath = await _generateScene(sceneList[index]);

      // 중단 체크
      if (isClosed) return;

      // 그림 목록 업데이트
      emit(
        state.copyWith(
          clueImagePathList: _replacedAt(
            imagePathList: state.clueImagePathList,
            index: index,
            imagePath: imagePath,
          ),
        ),
      );
    }

    // 그림 생성 완료 처리
    emit(state.copyWith(isGeneratingScenes: false));
  }

  ///
  /// 정답 제출 — 맞으면 결과를 기록하고 true, 틀리면 오답 신호만 올리고 false
  ///
  bool submit(String guess) {
    final String normalizedGuess = guess.trim();
    if (normalizedGuess.isEmpty) return false;
    final bool isCorrect = _scoringService.isCorrect(
      song: currentQuestion.song,
      guess: normalizedGuess,
    );
    if (!isCorrect) {
      emit(state.copyWith(wrongAnswerCount: state.wrongAnswerCount + 1));
      return false;
    }
    _recordResult(isCorrect: true);
    return true;
  }

  ///
  /// 답안 공개 — 그림이 다 그려진 뒤에만 열 수 있다
  ///
  /// 결과 화면은 그림 목록을 스냅샷으로 받으므로, 그리는 중에 열면
  /// 못 채운 칸이 그대로 남는다.
  ///
  bool revealAnswer() {
    if (state.isGeneratingScenes) {
      AppToastService.show('그림을 아직 그리고 있어요');
      return false;
    }
    _recordResult(isCorrect: false);
    return true;
  }

  ///
  /// 다음 문제로 넘어가 장면 생성을 다시 시작한다
  ///
  void goToNextQuestion() {
    emit(state.copyWith(qIndex: state.qIndex + 1));
    generateScenes();
    textController.clear();
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

  /// 첫 장면만 채워둔 초기 경로 목록
  List<String> _initialPathList({
    required int sceneCount,
    required String firstImagePath,
  }) =>
      List<String>.filled(sceneCount, '')..[0] = firstImagePath;

  /// 한 자리만 교체한 새 경로 목록
  List<String> _replacedAt({
    required List<String> imagePathList,
    required int index,
    required String imagePath,
  }) =>
      List<String>.of(imagePathList)..[index] = imagePath;

  /// 곡 메타를 힌트 항목 목록으로 변환
  List<HintItem> _buildHints(Song song) => <HintItem>[
        (label: '가수 초성', value: _toChoseong(song.artist)),
        (label: '발매연도', value: '${song.year}년'),
        (label: '장르', value: song.genre),
      ];

  /// 문자열의 한글 음절을 초성으로 변환, 그 외 문자는 그대로
  String _toChoseong(String text) => text.runes.map(_choseongOf).join();

  /// 코드포인트 1개를 초성으로 변환 (한글 음절이 아니면 원문 유지)
  String _choseongOf(int code) {
    const int base = 0xAC00;
    const int last = 0xD7A3;
    if (code < base || code > last) return String.fromCharCode(code);
    return _choseongTable[(code - base) ~/ 588];
  }
}
