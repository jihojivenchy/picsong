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

  /// 배치 내용 지문 — 캐시된 뷰모델을 갈아끼울지 판단하는 데 쓴다
  String get signature => trialList
      .map((PromptTrial trial) =>
          '${trial.prompt}|${trial.seed}|${trial.steps}')
      .join('\n');
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
  /// 74차 배치 — "비가 내리고 음악이 흐르면" 2장 구성
  ///
  /// - 1장: 비 · 2장: 음악
  ///
  /// **비는 이미 결론이 나 있어 슬롯을 셋만 쓴다.** 49~51차에서 26장을 태워
  /// 「공중의 빗줄기는 384px에서 표현 불가」를 확인했고, 살아남은 건 **물에 닿는 쪽**
  /// 하나였다(`rain on water` — `song_015` 채택본). 같은 실험을 반복하지 않는다.
  /// 여기서 볼 건 하나다 — **`song_015`와 겹치지 않는 비를 찾을 수 있는가.**
  /// 1번이 그 채택본이라 나란히 놓고 비교한다. 2번 창유리는 51차에 없던 각도이고,
  /// 3번은 채택본의 수면을 넓혀 구도만 바꾼 형태다.
  ///
  /// **우산은 일부러 뺐다.** 비의 도상으로는 강하지만 `song_015`의 제목이
  /// 「우산」이라, 우산이 나오면 플레이어를 그 곡으로 끌고 간다 — 단서가 아니라
  /// 노이즈다(§5-3).
  ///
  /// **음악(4~9번)이 이 배치의 본론이고, 여기엔 검증된 표현이 있다.**
  /// `black music notes`는 39차 채택본(`a large bronze bell with black music
  /// notes floating around it`)과 40차에서 이미 통과했다. 5번은 그 문장 골격을
  /// **`with ... floating around it` 형태 그대로** 라디오에 이식한 것이다 —
  /// "음악이 흐른다"를 `from`으로 쓰면 §4-7(A에서 나오는 B)에 걸리므로
  /// 검증된 `around` 구조를 쓴다.
  ///
  /// 6~9번은 음악의 사물 도상이다. 곡이 1986년이라 LP·라디오가 시대에도 맞고,
  /// 넷 다 단독 피사체로 학습량이 충분하다(§4-12).
  ///
  /// 시드는 8888 고정.
  ///
  static PromptLabBatch get first => PromptLabBatch(
    tag: 'prompt-lab-1',
    title: '프롬프트 실험실 1',
    trialList: <PromptTrial>[
      // 비 — 결론은 나 있다. song_015와 겹치지 않는 형태만 찾는다
      _trial(1, '비 — song_015 채택본(기준선)', 'rain on water'),
      _trial(2, '비 — 창유리', 'raindrops running down a window pane'),
      _trial(3, '비 — 넓은 수면', 'rain falling on a wide river'),

      // 음악 — `black music notes`는 39·40차에서 검증된 표현이다
      _trial(4, '음표 — 단독', 'black music notes floating in the air'),
      _trial(5, '음표 — 라디오(검증 골격 이식)',
          'an old radio with black music notes floating around it'),

      // 음악의 사물 도상 — 1986년 곡이라 LP·라디오가 시대에도 맞다
      _trial(6, 'LP', 'a vinyl record spinning on a turntable'),
      _trial(7, '라디오', 'an old radio with a round dial'),
      _trial(8, '피아노', 'a grand piano seen from the side'),
      _trial(9, '기타', 'an acoustic guitar leaning against a wall'),
    ],
  );

  ///
  /// 74차 배치 — 73차 3번(**나무 탁자 위 작은 술잔**)만 파고든다
  ///
  /// "한잔해, 한잔해, 한잔해" — 한 장으로 낸다.
  /// ```
  /// 73차 3번  a small shot glass on a wooden table
  /// ```
  /// 소주는 버렸고(§4-16), 건배·따르기 같은 동작도 밀렸다. 남은 건 **잔 하나가
  /// 탁자에 놓인 그림**이므로 골격을 그대로 두고 그 안에서만 움직인다.
  ///
  /// ① **가장 큰 변수는 잔이 비었느냐다(2·3·5번).** 빈 잔은 그냥 유리잔이고,
  ///    **액체가 보여야 「한잔」이 된다.** 73차 3번은 담긴 것을 말하지 않았다 —
  ///    빠져 있던 조합이 이것이다.
  ///    `clear liquor`는 색 단어가 아니라 투명도 서술이라 §4-5의 색 흘림을
  ///    부르지 않는다(71차와 같은 판단).
  ///
  /// ② **병을 곁들이면 술자리임이 분명해진다(4·5번).** 대신 잔이 주인공
  ///    자리를 뺏길 수 있다(§4-19). 4번은 잔이 주어, 5번은 병이 주어라
  ///    어느 쪽이 살아남는지 갈린다.
  ///
  /// ③ **배경과 시점(6~9번)** — 바 카운터·거친 나무결·낮은 상, 그리고 부감.
  ///    `seen from above`는 §4-18의 성공 사례에 들어 있는 표현이다.
  ///    9번의 낮은 상은 한국 술상에 가까우면서도 보편 형태라 §4-16을 통과한다.
  ///
  /// 1번은 73차 3번 원본이다. 비교 기준선이다.
  ///
  /// 시드는 8888 고정.
  ///
  static PromptLabBatch get second => PromptLabBatch(
        tag: 'prompt-lab-2',
        title: '프롬프트 실험실 2',
        trialList: <PromptTrial>[
          // 기준선 — 73차 3번 원본
          _trial(1, '기준선 — 73차 3번',
              'a small shot glass on a wooden table'),

          // 채워진 잔 — 액체가 보여야 「한잔」이 된다
          _trial(2, '채워짐',
              'a small shot glass filled with clear liquor on a wooden table'),
          _trial(3, '채워짐 — 짧게',
              'a filled shot glass on a wooden table'),

          // 병 곁들임 — 술자리임은 분명해지지만 잔이 밀릴 수 있다(§4-19)
          _trial(4, '병 곁들임 — 잔이 주어',
              'a small shot glass and a bottle on a wooden table'),
          _trial(5, '병 곁들임 — 병이 주어',
              'a bottle and a filled shot glass on a wooden table'),

          // 배경 · 시점 — 잔은 그대로 두고 놓인 자리만 바꾼다
          _trial(6, '바 카운터', 'a small shot glass on a bar counter'),
          _trial(7, '위에서 봄',
              'a small shot glass on a wooden table, seen from above'),
          _trial(8, '거친 나무결',
              'a small shot glass on a rough wooden table'),
          _trial(9, '낮은 상', 'a small shot glass on a low wooden table'),
        ],
      );

  ///
  /// 72차 배치 — 「사랑의 배터리」 "사랑의 밧데리가 다 됐나봐요" 2장 구성
  ///
  /// - 1장: 하트 · 2장: 배터리
  ///
  /// 제목의 두 낱말이 그대로 조각이 되므로 정답으로 곧장 이어진다(§5-3).
  ///
  /// **`다 됐나봐요`(방전)는 거의 버린 상태로 시작한다.** 실물 건전지는 방전돼도
  /// 겉모습이 똑같다 — §4-3이 말하는 "흔적을 남기지 않는 서술"이다. 방전을
  /// 보이게 하려면 **빈 게이지 아이콘**밖에 없는데 그건 §4-14(텍스트·UI 요소)
  /// 근처라 위험하다. 6·7번이 그 확인이고, 무너지면 「사랑 + 배터리」 두 장으로 낸다.
  ///
  /// ① **하트(1~2번)는 이미 답이 있다.** 1번은 `song_033`·`song_030`이 쓰고 있는
  ///    검증본이고 시드도 같으므로 **완전히 같은 그림**이 나온다.
  ///    2번은 금 간 하트 — 방전을 배터리가 아니라 하트로 옮겨보는 시도다.
  ///
  /// ② **배터리(3~9번)의 승부처는 「실물이냐 도형이냐」다.**
  ///    하트가 성공한 문장은 `flat solid color, clean rounded outline`이라는
  ///    **도형 지시**였다(§10 — 하트는 추상 도형이라 실패한 게 아니다).
  ///    그 골격을 배터리에 그대로 이식한 게 5~7번이고, 실물 건전지로 간 게 4·9번이다.
  ///
  /// ③ **8번은 한 장으로 끝낼 수 있는지 본다.** 하트 모양 배터리는 제목 자체다.
  ///    되면 2장이 아니라 1장 구성이 된다.
  ///
  /// `battery`는 §4-17 위험이 낮다 — 야구·포병 뜻이 있지만 이미지 쪽은 건전지가
  /// 압도적이다. 다만 4번의 `AA`는 글자라 무늬로 처리될 수 있다(§4-14).
  ///
  /// 시드는 8888 고정.
  ///
  static PromptLabBatch get third => PromptLabBatch(
    tag: 'prompt-lab-3',
    title: '프롬프트 실험실 3',
    trialList: <PromptTrial>[
      // 하트 — 1번은 songs.json이 이미 쓰는 검증본이라 기준선이다
      _trial(1, '하트 — 검증본',
          'A red heart shape, flat solid color, clean rounded outline'),
      _trial(2, '하트 — 금 간 하트',
          'a red heart shape with a crack down the middle'),

      // 배터리 — 실물 쪽
      _trial(3, '배터리 — 최단', 'a battery'),
      _trial(4, '배터리 — 건전지 실물', 'an AA battery standing upright'),

      // 배터리 — 도형 쪽. 하트가 성공한 문장 골격을 그대로 이식한다
      _trial(5, '배터리 — 도형 이식',
          'a battery icon, flat solid color, clean rounded outline'),
      _trial(6, '배터리 — 빈 게이지',
          'an empty battery icon, flat solid color'),
      _trial(7, '배터리 — 한 칸 남음',
          'a battery icon with one bar left, flat solid color'),

      // 한 장으로 끝내기 — 하트 모양 배터리는 제목 그 자체다
      _trial(8, '하트 배터리', 'a heart shaped battery, flat solid color'),

      // 방전 리터럴 — `dead`가 상태 지시라 무시될 공산이 크다(§4-18)
      _trial(9, '배터리 — 방전 리터럴',
          'a dead battery lying on the ground'),
    ],
  );

  /// 실험실 배치 전체 — 라우트가 tag로 배치를 되찾는 데 쓴다
  static List<PromptLabBatch> get values => <PromptLabBatch>[
        first,
        second,
        third,
      ];

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
