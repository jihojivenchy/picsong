import 'package:get/get.dart';
import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/presentation/screens/prompt_lab/prompt_lab_batch.dart';
import 'package:picsong/utils/services/app_logger.dart';

///
/// 프롬프트 실험실 컨트롤러
/// 주입받은 배치를 실기기에서 순서대로 생성해 원인을 가린다
///
/// 실험실마다 배치가 다르므로 인스턴스도 배치 태그로 분리해 등록한다.
///
class PromptLabController extends GetxController {
  /// 클루 생성 서비스
  final ClueService _clueService = ClueService();

  /// 이 실험실이 실행할 배치
  final PromptLabBatch batch;

  /// 실험 결과 목록 — 생성될 때마다 해당 항목이 교체된다
  final RxList<PromptTrial> trialList = <PromptTrial>[].obs;

  /// 실행 중 여부
  final RxBool isRunning = false.obs;

  /// 완료된 건수
  final RxInt doneCount = 0.obs;

  PromptLabController({required this.batch});

  /// 실행 전에도 배치가 보이도록 목록을 미리 채운다
  @override
  void onInit() {
    super.onInit();
    trialList.assignAll(batch.trialList);
  }

  ///
  /// 실험 배치를 처음부터 순서대로 실행한다
  ///
  Future<void> run() async {
    if (isRunning.value) return;
    _resetState();
    for (int index = 0; index < trialList.length; index++) {
      trialList[index] = await _runTrial(trialList[index]);
      doneCount.value = index + 1;
    }
    isRunning.value = false;
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

  /// 실행 상태를 초기화한다
  void _resetState() {
    isRunning.value = true;
    doneCount.value = 0;
    trialList.assignAll(batch.trialList);
  }
}
