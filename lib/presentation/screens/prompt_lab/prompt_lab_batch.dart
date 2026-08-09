import 'package:picsong/data/services/clue/clue_service.dart';
import 'package:picsong/domain/services/round/round_service.dart';

/// 실험 한 건 — 보낼 프롬프트와 받은 결과
class PromptTrial {
  /// 결과 화면에 붙는 짧은 라벨
  final String label;

  /// 네이티브로 그대로 보내는 프롬프트 전문 (프리픽스 포함 여부까지 이 문자열이 결정한다)
  final String prompt;

  /// 디노이징 스텝 수
  final int steps;

  /// 생성 시드 — 같은 대상끼리 맞춰야 프리픽스·스텝 비교가 성립한다
  final int seed;

  /// 생성된 이미지 경로 — 아직 생성 전이면 빈 문자열
  final String imagePath;

  /// 실패 사유 — 성공이면 빈 문자열
  final String error;

  const PromptTrial({
    required this.label,
    required this.prompt,
    required this.steps,
    required this.seed,
    this.imagePath = '',
    this.error = '',
  });

  PromptTrial copyWith({String? imagePath, String? error}) => PromptTrial(
        label: label,
        prompt: prompt,
        steps: steps,
        seed: seed,
        imagePath: imagePath ?? this.imagePath,
        error: error ?? this.error,
      );
}

/// 실험실 하나가 실행할 배치 — 실험실은 배치 하나당 하나씩 뜬다
class PromptLabBatch {
  /// 뷰모델 캐시 키 — 실험실마다 뷰모델과 결과가 따로 산다
  final String tag;

  /// 앱바에 표시할 실험실 이름
  final String title;

  /// 순서대로 실행할 실험 목록
  final List<PromptTrial> trialList;

  const PromptLabBatch({
    required this.tag,
    required this.title,
    required this.trialList,
  });
}

///
/// 실험실별 배치 정의
///
/// 실험실을 늘리려면 여기에 배치를 추가하고 홈에 진입 버튼을 붙인다.
/// 생성은 네이티브에서 직렬화되므로 실험실을 늘려도 동시에 그려지지는 않는다 —
/// 늘리는 이유는 **배치를 여러 벌 살려두기 위해서**다.
///
abstract class PromptLabBatches {
  /// 실험 기본 시드 — **게임이 쓰는 시드를 그대로 가져온다**
  ///
  /// 곡 번호에서 시드를 파생하던 시절에는 실험실 채택본과 게임 화면이 서로 달랐다.
  /// 같은 숫자를 양쪽이 따로 들고 있으면 언젠가 또 갈라지므로 직접 참조한다.
  static const int _fixedSeed = RoundService.imageSeed;

  /// 화풍 프리픽스 — **게임이 붙이는 것을 그대로 가져온다**
  ///
  /// 실험실은 `generateRawImage`로 프리픽스까지 직접 만들어 보내므로,
  /// 이 값이 게임과 다르면 같은 장면을 써도 다른 그림이 나온다.
  static const String _prefix = ClueService.stylePrefix;

  ///
  /// 58차 배치 — 「칵테일 사랑」(song_006) 첫째 줄 3장 구성
  ///
  /// "마음 울적한 날엔 거리를 걸어 보고 향기로운 칵테일에 취해도 보고"
  ///
  /// - 1장: 쓸쓸히 거리를 걷는 여자
  /// - 2장: 칵테일
  /// - 3장: 취한 여자
  ///
  /// **`향기로운`은 버렸다.** 후각은 그릴 수 없다(§7). 칵테일 잔이 그 자리를 대신한다.
  ///
  /// 조각마다 1번이 요청 그대로의 리터럴이고, 2·3번이 그 변형이다.
  ///
  /// ① **울적함(1~3번)** — 감정 단독은 §6의 제외 대상이라 **물리적 증거**로 옮긴다.
  ///    §4-3이 「울적하다 → 숙인 고개」를 직접 처방해 뒀다. 3번은 §4-11대로
  ///    뒷모습으로 잡아 얼굴 붕괴 여지를 없애고, 빈 거리로 쓸쓸함을 만든다.
  ///
  /// ② **칵테일(4~6번)은 가장 쉽다.** 잔은 실루엣이 특징적인 단독 피사체다.
  ///    다만 **색은 넣지 않는다** — 칵테일은 표준색이 없어서 §4-5의 색 흘림에
  ///    정면으로 걸린다. 레몬만 예외로 쓴다(노랑이 내장색).
  ///
  /// ③ **취함(7~9번)이 승부처다.** §4-3이 「취하다 → 붉게 상기된 볼, 감은 눈」을
  ///    처방했지만 그 뒤 §4-18에서 `eyes closed`가 24차에 6장 중 5장 실패했다.
  ///    그래서 눈은 건드리지 않고 `flushed`만 쓴다 — 색 단어가 아니라 상태어라
  ///    §4-5의 색 흘림에서도 비교적 안전하다. 8번은 §4-18의 성공 패턴대로
  ///    **상태를 지시하는 대신 그 상태가 당연한 상황**(테이블에 엎드림)을 준다.
  ///
  /// 시드는 8888 고정.
  ///
  static final PromptLabBatch first = PromptLabBatch(
    tag: 'prompt-lab-1',
    title: '프롬프트 실험실 1',
    trialList: <PromptTrial>[
      // 거리를 걷는 여자 — 울적함은 숙인 고개로 옮긴다(§4-3)
      _trial(1, '거리 — 리터럴', 'a woman walking alone down a city street'),
      _trial(2, '거리 — 숙인 고개',
          'a woman walking alone down a street, head lowered'),
      _trial(3, '거리 — 뒷모습',
          'a woman seen from behind walking down an empty street'),

      // 칵테일 — 색은 넣지 않는다(§4-5). 잔의 형태만 바꾼다
      _trial(4, '칵테일 — 리터럴', 'a cocktail glass on a table'),
      _trial(5, '칵테일 — 마티니 잔',
          'a martini glass with a slice of lemon on the rim'),
      _trial(6, '칵테일 — 롱드링크',
          'a tall cocktail glass with ice and a straw'),

      // 취한 여자 — 눈은 건드리지 않는다(§4-18). 표정·상황·소품으로 나눈다
      _trial(7, '취함 — 리터럴', 'a drunk woman with flushed cheeks'),
      _trial(8, '취함 — 상황',
          'a woman resting her head on a table, a glass beside her'),
      _trial(9, '취함 — 소품',
          'a woman holding a cocktail glass, flushed face'),
    ],
  );

  ///
  /// 59차 배치 — 「네모의 꿈」(song_010) 첫째 줄 2장 구성. **색 통일이 승부처다**
  ///
  /// "네모난 침대에서 일어나 눈을 떠보면 네모난 창문으로 보이는 똑같은 풍경"
  ///
  /// - 1장: 네모난 침대에서 일어나는 사람
  /// - 2장: 네모난 창문을 보는 사람
  ///
  /// **`square`만으로는 아무것도 달라지지 않는다.** 침대도 창문도 원래 사각형이라
  /// 그 단어가 화면에 만드는 변화가 없다. 두 장을 「네모의 꿈」으로 읽히게 하는
  /// 건 결국 **두 장이 같은 색을 공유하는 것**뿐이다. 색을 변수로 돌리는 이유다.
  ///
  /// **그런데 그게 §4-5 정면이다.** 침대와 창문은 표준색이 없는 대상이라
  /// 색을 붙이면 옆으로 샌다(「좋은 날」에서 빨강이 눈 대신 눈물 자국에 붙었다).
  /// 다만 하트는 `A red heart shape, flat solid color`로 성공했다 — 9번이
  /// 그 표현을 그대로 이식해, 색이 안 붙는 게 대상 탓인지 표현 탓인지 가른다.
  ///
  /// **어순 트레이드오프가 하나 더 있다.** 요청대로 사람을 주어로 두면
  /// (`a person sitting up in a square bed`) 침대가 12번째로 밀려 §1에 걸린다.
  /// 그래서 1·5번만 리터럴로 두고, 2~8번은 **네모난 사물을 주어로 올렸다**(§4-1).
  ///
  /// 색은 침대·창문에 같은 순서로 걸었다 — **2·6(파랑) / 3·7(빨강) / 4·8(노랑)**
  /// 짝으로 보면 한 색이 두 장 모두에서 버티는지 바로 읽힌다.
  ///
  /// 시드는 8888 고정.
  ///
  static final PromptLabBatch second = PromptLabBatch(
    tag: 'prompt-lab-2',
    title: '프롬프트 실험실 2',
    trialList: <PromptTrial>[
      // 침대 — 1번만 요청 그대로의 리터럴, 나머지는 침대를 주어로 올린다
      _trial(1, '침대 — 리터럴(무색)', 'a person sitting up in a square bed'),
      _trial(2, '침대 — 파랑', 'a blue square bed with a person sitting up'),
      _trial(3, '침대 — 빨강', 'a red square bed with a person sitting up'),
      _trial(4, '침대 — 노랑', 'a yellow square bed with a person sitting up'),

      // 창문 — 침대와 같은 색 순서로 건다. 짝지어 비교하기 위해서다
      _trial(5, '창문 — 리터럴(무색)', 'a person looking out a square window'),
      _trial(6, '창문 — 파랑',
          'a blue square window with a person looking out'),
      _trial(7, '창문 — 빨강',
          'a red square window with a person looking out'),
      _trial(8, '창문 — 노랑',
          'a yellow square window with a person looking out'),

      // 색만 진단 — 하트가 성공한 표현을 이식해 색이 사물에 붙는지 본다(§4-5)
      _trial(9, '색 진단 — 평면색', 'a blue square window, flat solid color'),
    ],
  );

  /// 실험실 배치 전체 — 라우트가 tag로 배치를 되찾는 데 쓴다
  static final List<PromptLabBatch> values = <PromptLabBatch>[first, second];

  ///
  /// tag에 해당하는 배치 (미상이면 첫 배치)
  ///
  static PromptLabBatch fromTag(String tag) => values.firstWhere(
        (PromptLabBatch batch) => batch.tag == tag,
        orElse: () => first,
      );

  ///
  /// 게임과 같은 프리픽스를 붙여 실험 한 건을 만든다
  ///
  static PromptTrial _trial(
    int number,
    String label,
    String scene, {
    int steps = 4,
    int? seed,
  }) {
    return PromptTrial(
      label: '$number. $label',
      prompt: '$_prefix$scene',
      steps: steps,
      seed: seed ?? _fixedSeed,
    );
  }
}
