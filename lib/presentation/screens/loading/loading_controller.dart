import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picsong/data/dio/error/error_exception_type.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/data/services/song/song_service.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/domain/services/round/round_service.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/presentation/screens/question/question_screen.dart';
import 'package:picsong/utils/services/app_logger.dart';

/// 로딩(그림 생성) 화면 컨트롤러
class LoadingController extends GetxController {
  /// 진행률 바 연출 시간 — 실제 생성 시간과는 무관하다
  static const Duration generationDuration = Duration(seconds: 3);

  /// 한 라운드의 문제 수
  static const int _questionCount = 5;

  /// 생성 대상 시대
  final Era era;

  LoadingController({required this.era});

  /// 곡 데이터 서비스
  final SongService _songService = SongService();

  /// 라운드 구성 서비스
  final RoundService _roundService = RoundService();

  /// 온디바이스 클루 이미지 생성 서비스
  final ClueService _clueService = ClueService();

  /// 화면 진입과 동시에 라운드 준비 시작
  @override
  void onInit() {
    super.onInit();
    _prepareRound();
  }

  ///
  /// 라운드를 구성하고 첫 문제 이미지를 생성한 뒤 퀴즈 화면으로 진입
  ///
  Future<void> _prepareRound() async {
    try {
      final List<Question> questionList = await _buildQuestionList();
      final Question first = questionList.first;
      final String firstImagePath = await _clueService.generateClueImage(
        scene: first.lyricLine.imagePrompt,
        seed: first.imageSeed,
      );
      if (isClosed) return;
      Get.off(
        () => QuestionScreen(
          era: era,
          questionList: questionList,
          firstImagePath: firstImagePath,
        ),
      );
    } catch (error) {
      AppLogger.error('라운드 준비 실패', error: error);
      _goHomeWithMessage();
    }
  }

  ///
  /// 시대의 곡을 조회해 이번 라운드의 문제 목록을 만든다
  ///
  Future<List<Question>> _buildQuestionList() async {
    final List<Song> songList = await _songService.fetchSongListOf(era);
    final List<Question> questionList = _roundService.buildRound(
      songList: songList,
      count: _questionCount,
      random: Random(),
    );
    if (questionList.isEmpty) {
      throw SongDataException('${era.label} 곡을 찾지 못했습니다');
    }
    return questionList;
  }

  /// 준비 실패를 알리고 홈으로 되돌린다
  void _goHomeWithMessage() {
    if (isClosed) return;
    AppToastService.show('문제를 준비하지 못했어요');
    Get.until((Route<dynamic> route) => route.isFirst);
  }
}
