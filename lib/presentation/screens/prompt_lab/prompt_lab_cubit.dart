import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';
import 'package:picsong/utils/services/app_logger.dart';

part 'prompt_lab_state.dart';

///
/// 프롬프트 실험실 뷰모델
/// 주입받은 배치를 실기기에서 순서대로 생성해 원인을 가린다
///
/// 실험실마다 배치가 다르므로 인스턴스도 배치 단위로 분리해 살려둔다.
///
class PromptLabCubit extends Cubit<PromptLabState> {
  /// 이 실험실이 실행할 배치
  final PromptLabBatch batch;

  /// 실행 전에도 배치가 보이도록 목록을 채운 상태로 시작한다
  PromptLabCubit({required this.batch})
      : super(PromptLabState(trialList: batch.trialList));

  /// 클루 생성 서비스
  final ClueService _clueService = ClueService();

  ///
  /// 실험 배치를 처음부터 순서대로 실행한다
  ///
  Future<void> run() async {
    if (state.isRunning) return;
    emit(
      state.copyWith(
        trialList: batch.trialList,
        isRunning: true,
        doneCount: 0,
      ),
    );
    for (int index = 0; index < state.trialList.length; index++) {
      final PromptTrial trial = await _runTrial(state.trialList[index]);
      emit(
        state.copyWith(
          trialList: _replacedAt(
            trialList: state.trialList,
            index: index,
            trial: trial,
          ),
          doneCount: index + 1,
        ),
      );
    }
    emit(state.copyWith(isRunning: false));
  }

  /// 실험 한 건을 생성해 결과가 채워진 새 객체를 반환
  Future<PromptTrial> _runTrial(PromptTrial trial) async {
    try {
      final String path = await _clueService.generateRawImage(
        prompt: trial.prompt,
        seed: trial.seed,
        steps: trial.steps,
      );
      return trial.copyWith(imagePath: path);
    } catch (error) {
      AppLogger.error('프롬프트 실험 실패: ${trial.label}', error: error);
      return trial.copyWith(error: error.toString());
    }
  }

  /// 한 자리만 교체한 새 목록을 반환 (순수)
  List<PromptTrial> _replacedAt({
    required List<PromptTrial> trialList,
    required int index,
    required PromptTrial trial,
  }) =>
      List<PromptTrial>.of(trialList)..[index] = trial;
}
