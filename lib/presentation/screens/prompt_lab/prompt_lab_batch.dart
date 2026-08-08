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
  /// GetX 인스턴스 구분 태그 — 실험실마다 컨트롤러와 결과가 따로 산다
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
  /// 실험 기본 시드 — 조건 차이만 보려면 시드를 고정해야 한다
  ///
  /// 채택 직전 검증에는 이 값 대신 **게임이 실제로 쓸 시드**를 넘긴다.
  /// 게임 시드는 곡 번호에서 파생된다 — `RoundService._imageSeedOf` 참조.
  /// `곡번호 * 1000 + 가사줄 순번 * 10 + 장면 순번` (song_039 첫 장면 → 39000)
  static const int _fixedSeed = 8888;

  /// 게임이 실제로 붙이는 화풍 프리픽스 — 3토큰
  static const String _prefix = 'gouache painting, ';

  ///
  /// 56차 배치 — 53차 7번(**다리가 주어인 문장**) 하나만 벌린다
  ///
  /// 「하늘을 달리다」(song_011) — "설혹 너무 태양 가까이 날아 두 다리 모두 녹아 내린다고 해도".
  /// 3장 중 둘은 채택됐다.
  /// ```
  /// 1장 태양 a blazing sun high in an empty sky, bright yellow light spreading outward
  /// 2장 비행 a person flying close to the sun            (53차 3번)
  /// ```
  /// 남은 3장은 53차 7번 `melting legs on a human figure`가 유력 후보다.
  /// **그 문장 골격은 건드리지 않는다** — `melting legs`를 맨 앞에 두는 어순이
  /// 53차에서 유일하게 살아남은 형태이고, §4-1(그리려는 것이 주어)에도 맞는다.
  ///
  /// 바꾸는 것은 넷뿐이다.
  /// ① **대상 명사**(2~3번) — `human figure`가 인체 모형처럼 나올 수 있다.
  ///    `person`·`man`으로 바꿨을 때 사람다워지는지 본다.
  /// ② **상태 어휘**(4~5번) — 진행형 대신 완료형(`melted`), 그리고 `dissolving`.
  ///    §4-18대로 진행 상태가 무시된다면 완료형이 더 유리할 수 있다.
  /// ③ **녹음의 증거·부위**(6~7번) — 흘러내리는 자국을 명시하거나(§4-3),
  ///    다리 대신 하반신 전체로 범위를 넓힌다.
  /// ④ **맥락과 길이**(8~9번) — 가사대로 하늘을 넣은 형태, 그리고 최단형.
  ///    9번은 사람 없이 다리만 부르는데, §4-9대로라면 복수 `legs`가 오히려
  ///    사람을 불러올 수 있다. 그렇게 나오면 그게 최선의 문장이다.
  ///
  /// 1번은 53차 7번 원본이다. 시드가 같아 같은 그림이 나오므로 맨 위에서
  /// **비교 기준선** 노릇을 한다.
  ///
  /// 시드는 8888 고정.
  ///
  static final PromptLabBatch first = PromptLabBatch(
    tag: 'prompt-lab-1',
    title: '프롬프트 실험실 1',
    trialList: <PromptTrial>[
      // 기준선 — 53차 7번 원본
      _trial(1, '기준선 — 53차 7번', 'melting legs on a human figure'),

      // 대상 명사 — `human figure`가 인체 모형처럼 나올 위험을 본다
      _trial(2, '대상 — person', 'melting legs on a person'),
      _trial(3, '대상 — man', 'melting legs on a man'),

      // 상태 어휘 — 진행형이 무시된다면 완료형이 유리할 수 있다(§4-18)
      _trial(4, '완료형', 'melted legs on a human figure'),
      _trial(5, '용해', 'dissolving legs on a human figure'),

      // 녹음의 증거·부위 — 흘러내린 자국, 그리고 하반신 전체
      _trial(6, '흘러내림 자국',
          'melting legs on a human figure, drips running down'),
      _trial(7, '하반신 전체', 'a melting lower body on a human figure'),

      // 맥락과 길이 — 가사대로 하늘, 그리고 최단형
      _trial(8, '하늘 맥락', 'melting legs on a human figure in the sky'),
      _trial(9, '최단', 'melting legs'),
    ],
  );

  ///
  /// 57차 배치 — 「깊은 밤을 날아서」(song_005) 첫째 줄 3장 구성
  ///
  /// "고운 그대 손을 잡고 밤하늘을 날아서 궁전으로 갈 수도 있어"
  ///
  /// - 1장: 손을 잡는 모습
  /// - 2장: 밤하늘을 나는 모습 — 넷째 줄 채택본을 그대로 쓴다
  /// - 3장: 궁전
  ///
  /// 2장은 이미 답이 있으므로(`a person flying in the night sky`) 확인용 1건만
  /// 싣고, 나머지 8건을 손잡기와 궁전에 4·4로 나눈다.
  ///
  /// ① **손잡기(1~4번)는 §4-9에 정면으로 걸린다.** 문서가 `both hands`를
  ///    실패 사례로 못 박았다 — 복수 신체 부위는 전신 인물로 되돌아가거나
  ///    한쪽만 그려진다. 그런데 손잡기는 손이 둘인 게 본질이라 단수 프레이밍이
  ///    불가능하다. 그래서 갈래를 둘로 벌린다. **사람을 주어로 두면**(1~2번)
  ///    전신으로 되돌아가도 그게 곧 정답 그림이고, **손만 부르면**(3~4번)
  ///    §4-9대로 깨질 위험을 무릅쓰고 손 클로즈업을 노린다.
  ///
  /// ② **궁전(6~9번)은 song_007과 겹치면 안 된다.** 「마법의 성」이 이미
  ///    `a fairytale castle with tall pointed towers on a hill`을 쓰고 있다.
  ///    뾰족한 탑이 또 나오면 두 곡의 그림이 헷갈린다. 그래서 castle이 아니라
  ///    **palace의 도상**(넓은 대칭 파사드·돔·기둥)으로 몰아간다.
  ///
  /// 시드는 8888 고정.
  ///
  static final PromptLabBatch second = PromptLabBatch(
    tag: 'prompt-lab-2',
    title: '프롬프트 실험실 2',
    trialList: <PromptTrial>[
      // 손잡기 A — 사람이 주어. 전신으로 되돌아가도 그게 정답 그림이다
      _trial(1, '커플 — 최단', 'a couple holding hands'),
      _trial(2, '커플 — 뒷모습',
          'a couple holding hands, seen from behind'),

      // 손잡기 B — 손만 부른다. §4-9대로라면 깨지는 쪽이다
      _trial(3, '손만 — 복수(대조군)', 'two hands clasped together'),
      _trial(4, '손만 — 단수 프레이밍', 'a hand holding another hand'),

      // 밤하늘 비행 — 넷째 줄 채택본. 시드가 같아 확인용이다
      _trial(5, '비행 — 채택본', 'a person flying in the night sky'),

      // 궁전 — castle이 아니라 palace의 도상으로 간다
      _trial(6, '궁전 — 대칭 파사드',
          'a grand palace with a wide symmetric facade'),
      _trial(7, '궁전 — 돔과 아치', 'a golden palace with domes and arches'),
      _trial(8, '궁전 — 기둥', 'a white marble palace with tall columns'),
      _trial(9, '궁전 — 밤하늘 맥락',
          'a fairytale palace glowing in the night sky'),
    ],
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
