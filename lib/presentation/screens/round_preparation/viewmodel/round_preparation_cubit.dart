import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/error/error_exception_type.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/data/services/song/song_service.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/domain/entities/question/question.dart';
import 'package:picsong/domain/entities/song/song.dart';
import 'package:picsong/domain/services/round/round_service.dart';
import 'package:picsong/presentation/common/services/app_toast_service.dart';
import 'package:picsong/utils/services/app_logger.dart';

part 'round_preparation_state.dart';

/// 퀴즈 화면 진입에 필요한 라운드 준비 결과
typedef PreparedRound = ({List<Question> questionList, String firstImagePath});

/// 라운드 준비(곡 선정 + 첫 그림 생성) 화면 뷰모델
class RoundPreparationCubit extends Cubit<RoundPreparationState> {
  /// 생성 대상 시대
  final Era era;

  RoundPreparationCubit({required this.era})
      : super(const RoundPreparationState());

  /// 한 라운드의 문제 수
  static const int _questionCount = 5;

  /// 곡 데이터 서비스
  final SongService _songService = SongService();

  /// 라운드 구성 서비스
  final RoundService _roundService = RoundService();

  /// 온디바이스 클루 이미지 생성 서비스
  final ClueService _clueService = ClueService();

  ///
  /// 라운드 준비 — 성공하면 퀴즈 진입 재료를, 실패하면 null을 돌려준다
  ///
  Future<PreparedRound?> prepareRound() async {
    try {
      // 퀴즈 리스트 구성
      final List<Question> questionList = await _buildQuestionList();

      // 첫 문제 이미지 생성
      final Question first = questionList.first;
      final String firstImagePath = await _clueService.generateClueImage(
        scene: first.firstScene.imagePrompt,
        seed: first.firstScene.imageSeed,
      );
      return (questionList: questionList, firstImagePath: firstImagePath);
    } catch (error) {
      AppLogger.error('라운드 준비 실패', error: error);
      // 화면이 이미 닫혔으면 준비 실패를 알리지 않는다
      if (!isClosed) AppToastService.show('문제를 준비하지 못했어요');
      return null;
    }
  }

  ///
  /// 퀴즈 리스트 구성
  ///
  Future<List<Question>> _buildQuestionList() async {
    // 시대의 곡 목록 조회
    final List<Song> songList = await _songService.fetchSongListOf(era);

    // 퀴즈 리스트 구성
    final List<Question> questionList = _roundService.buildRound(
      songList: songList,
      count: _questionCount,
      random: Random(),
    );

    // 퀴즈 리스트가 비어있으면 예외 발생
    if (questionList.isEmpty) {
      throw SongDataException('${era.label} 곡을 찾지 못했습니다');
    }

    // 퀴즈 리스트 반환
    return questionList;
  }
}
