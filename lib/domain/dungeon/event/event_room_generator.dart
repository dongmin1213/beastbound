import 'dart:math';

import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/domain/dungeon/event/job_event_variants.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

/// 이벤트 방 생성기 — static 팩토리 (MysteryResultGenerator 패턴).
/// 시드 기반 PRNG로 결정론적 이벤트 선택.
class EventRoomGenerator {
  EventRoomGenerator._();

  /// 이벤트 방 데이터 생성.
  /// [floor] 현재 층 (향후 층별 이벤트 풀 확장용).
  /// [eventConfig] 보상/페널티 값.
  /// [dispositionConfig] 성향 보상 값.
  /// [seed] PRNG 시드 — 같은 시드 = 같은 이벤트.
  /// [playerJobId] 플레이어 직업 ID — 직업별 추가 선택지 제공.
  /// [unlockedMemoryCount] 해금된 기억 수 — 히든 이벤트 조건.
  /// [hasCurses] 저주 활성 여부 — 히든 이벤트 조건.
  static EventRoomData generate({
    required int floor,
    required EventConfig eventConfig,
    DispositionConfig dispositionConfig = const DispositionConfig(),
    int? seed,
    String? playerJobId,
    int unlockedMemoryCount = 0,
    bool hasCurses = false,
  }) {
    // 층별 보상 스케일링: 1층=1.0x, 2층=1.15x, 3층=1.3x, 4층=1.45x, 5층=1.6x
    final scaledConfig = eventConfig.scaledForFloor(floor);
    final events = _buildEventPool(scaledConfig, dispositionConfig);
    final hiddenEvents = _buildHiddenEventPool(
      scaledConfig,
      dispositionConfig,
      floor,
      unlockedMemoryCount: unlockedMemoryCount,
      hasCurses: hasCurses,
    );
    final random = Random(seed);

    // 2단계 롤: base(85%) / hidden(15%) — 히든 풀이 비어있으면 항상 base
    final EventRoomData baseEvent;
    if (hiddenEvents.isNotEmpty && random.nextDouble() < 0.15) {
      baseEvent = hiddenEvents[random.nextInt(hiddenEvents.length)];
    } else {
      baseEvent = events[random.nextInt(events.length)];
    }

    // 직업별 변형 선택지 추가
    final variant = JobEventVariants.getVariant(baseEvent.title, playerJobId);
    if (variant != null) {
      return EventRoomData(
        title: baseEvent.title,
        narrativeText: baseEvent.narrativeText,
        choices: [...baseEvent.choices, variant],
      );
    }

    return baseEvent;
  }

  /// 이벤트 풀 19개.
  /// EventConfig에서 보상/페널티 값, DispositionConfig에서 성향 보상 값 참조.
  static List<EventRoomData> _buildEventPool(
      EventConfig config, DispositionConfig dConfig) {
    return [
      // 이벤트 1: 길을 잃은 여행자
      EventRoomData(
        title: '길을 잃은 여행자',
        narrativeText: '어두운 통로 한편에 지친 여행자가 앉아 있다. 당신을 보며 간절한 눈빛을 보낸다.',
        choices: [
          EventChoice(
            label: '도움을 준다',
            outcomeText: '감사의 표시로 여행자가 금화를 건넨다.',
            goldChange: config.goldReward,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '무시하고 지나간다',
            outcomeText: '여행자의 시선을 피해 걸음을 옮긴다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '짐을 약탈한다',
            outcomeText: '여행자가 저항했지만... 결국 금화를 빼앗았다.',
            goldChange: (config.goldReward * 1.5).round(),
            hpChange: -config.hpPenalty,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMajorReward,
              DispositionAxis.struggle: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 2: 깨진 제단
      EventRoomData(
        title: '깨진 제단',
        narrativeText: '고대 제단의 잔해가 놓여 있다. 희미한 빛이 금이 간 돌 사이로 새어나온다.',
        choices: [
          EventChoice(
            label: '기도한다',
            outcomeText: '온기가 몸을 감싼다. 상처가 아물어간다. 하지만 제단에 바친 금화가 사라졌다.',
            goldChange: -(config.goldReward / 2).round(),
            hpChange: config.hpReward,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMediumReward,
              DispositionAxis.wisdom: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '지나간다',
            outcomeText: '의미 없는 유적일 뿐이다. 걸음을 재촉한다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 3: 수상한 상인
      EventRoomData(
        title: '수상한 상인',
        narrativeText: '그림자 속에서 두건을 쓴 인물이 나타난다. \'거래할 생각이 있나?\'라고 속삭인다.',
        choices: [
          EventChoice(
            label: '거래한다',
            outcomeText: '의심스러운 약을 마셨다. 놀랍게도 효과가 있다.',
            goldChange: -(config.goldReward / 2).round(),
            hpChange: config.hpReward,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '거절한다',
            outcomeText: '현명한 선택이야... 아마도. 상인이 어둠 속으로 사라진다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMediumReward,
            },
          ),
        ],
      ),
      // 이벤트 4: 고대 무기고
      EventRoomData(
        title: '고대 무기고',
        narrativeText: '먼지 쌓인 무기고가 나타난다. 벽면에 걸린 무기들이 희미하게 빛나고 있다.',
        choices: [
          EventChoice(
            label: '무기를 수련한다',
            outcomeText: '고대 무기의 기운이 당신의 기술을 갈고닦는다.',
            goldChange: 0,
            hpChange: 0,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '남겨두고 떠난다',
            outcomeText: '무기고 입구에서 떨어진 금화 몇 닢을 주웠다.',
            goldChange: config.goldReward,
            hpChange: 0,
          ),
        ],
      ),
      // 이벤트 5: 저주받은 카드
      EventRoomData(
        title: '저주받은 카드',
        narrativeText: '바닥에 어둠의 기운이 서린 카드 한 장이 놓여 있다. 불길한 힘이 느껴진다.',
        choices: [
          EventChoice(
            label: '카드를 버린다',
            outcomeText: '저주의 기운과 함께 불필요한 기술이 사라진다.',
            goldChange: 0,
            hpChange: 0,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '힘을 흡수한다',
            outcomeText: '어둠의 힘이 몸을 관통한다. 고통스럽지만 새로운 기술을 얻었다.',
            goldChange: 0,
            hpChange: -10,
            cardRewardId: 'colorless_random',
          ),
        ],
      ),
      // 이벤트 6: 은둔 스승
      EventRoomData(
        title: '은둔 스승',
        narrativeText: '동굴 깊은 곳에서 한 노인이 명상하고 있다. 눈을 뜨며 당신을 바라본다.',
        choices: [
          EventChoice(
            label: '가르침을 받는다',
            outcomeText: '스승의 가르침으로 기존 기술이 한 단계 성장한다.',
            goldChange: -15,
            hpChange: 0,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '존경을 표하고 떠난다',
            outcomeText: '노인이 미소 짓는다. 따뜻한 기운이 마음을 감싼다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMediumReward,
            },
          ),
        ],
      ),
      // 이벤트 7: 잊혀진 보물상자
      EventRoomData(
        title: '잊혀진 보물상자',
        narrativeText: '벽감 속에 먼지 쌓인 보물상자가 있다. 자물쇠 주변에 함정 장치가 보인다.',
        choices: [
          EventChoice(
            label: '함정을 무시하고 연다',
            outcomeText: '함정이 발동했지만 보물을 손에 넣었다!',
            goldChange: 20,
            hpChange: -8,
          ),
          EventChoice(
            label: '조심스럽게 해체한다',
            outcomeText: '함정을 해체하고 상자를 열었다. 보물은 절반뿐이다.',
            goldChange: 10,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 8: 영혼의 샘
      EventRoomData(
        title: '영혼의 샘',
        narrativeText: '영롱한 빛을 내는 샘물이 고여 있다. 영혼의 기운이 느껴진다.',
        choices: [
          EventChoice(
            label: '마신다',
            outcomeText: '샘물이 몸의 상처를 치유한다. 동시에 약한 기술 하나가 씻겨 내려간다.',
            goldChange: 0,
            hpChange: 15,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '씻는다',
            outcomeText: '샘물에 몸을 씻자 불필요한 기운이 빠져나간다.',
            goldChange: 0,
            hpChange: 0,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 9: 전사의 유령
      EventRoomData(
        title: '전사의 유령',
        narrativeText: '갑옷을 입은 유령이 나타나 당신에게 검을 겨눈다. 결투를 원하는 듯하다.',
        choices: [
          EventChoice(
            label: '결투를 받는다',
            outcomeText: '치열한 결투 끝에 유령이 미소 짓는다. 기술이 날카로워졌다.',
            goldChange: 0,
            hpChange: -5,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '유령을 위로한다',
            outcomeText: '유령이 고개를 숙이며 안식을 찾는다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMajorReward,
            },
          ),
        ],
      ),
      // 이벤트 10: 붕괴하는 길
      EventRoomData(
        title: '붕괴하는 길',
        narrativeText: '앞의 통로가 무너지기 시작한다. 빨리 결정해야 한다.',
        choices: [
          EventChoice(
            label: '달려간다',
            outcomeText: '먼지를 뒤집어쓰며 간신히 통과했다. 투쟁의 의지가 불타오른다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '안전한 길을 찾는다',
            outcomeText: '우회하느라 시간과 금화를 소비했지만 안전하다.',
            goldChange: -5,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
            },
          ),
        ],
      ),
      // 이벤트 11: 이상한 거래
      EventRoomData(
        title: '이상한 거래',
        narrativeText: '공허한 눈의 존재가 나타난다. \'네 기술 하나를 다른 것과 바꿔주지.\'',
        choices: [
          EventChoice(
            label: '카드를 교환한다',
            outcomeText: '기존 기술이 사라지고 새로운 기술이 스며든다.',
            goldChange: 0,
            hpChange: 0,
            removeRandomCard: true,
            cardRewardId: 'colorless_random',
          ),
          EventChoice(
            label: '거래를 거부한다',
            outcomeText: '단호한 거부. 의지가 강해진다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMediumReward,
            },
          ),
        ],
      ),
      // 이벤트 12: 수정 동굴
      EventRoomData(
        title: '수정 동굴',
        narrativeText: '벽면 가득 수정이 빛나는 동굴이 나타난다. 아름다운 광경이다.',
        choices: [
          EventChoice(
            label: '수정을 채취한다',
            outcomeText: '수정을 채취해 금화로 바꿀 수 있다.',
            goldChange: 25,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '빛을 흡수한다',
            outcomeText: '수정의 빛이 몸을 감싸며 상처가 아문다.',
            goldChange: 0,
            hpChange: 10,
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 13: 갈림길의 석상
      EventRoomData(
        title: '갈림길의 석상',
        narrativeText: '두 갈래 길 사이에 석상이 서 있다. 왼손에는 검, 오른손에는 방패를 들고 있다.',
        choices: [
          EventChoice(
            label: '검을 만진다',
            outcomeText: '석상의 검에서 힘이 흘러들어온다. 공격 기술이 날카로워진다.',
            goldChange: 0,
            hpChange: 0,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '방패를 만진다',
            outcomeText: '석상의 방패에서 따뜻한 기운이 퍼진다. 상처가 치유된다.',
            goldChange: 0,
            hpChange: config.hpReward,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '금화를 바친다',
            outcomeText: '석상이 빛나며 두 가지 축복이 동시에 내려온다.',
            goldChange: -15,
            hpChange: 5,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMediumReward,
            },
          ),
        ],
      ),
      // 이벤트 14: 독 웅덩이
      EventRoomData(
        title: '독 웅덩이',
        narrativeText: '바닥에 초록빛 액체가 고여 있다. 독인지 약인지 알 수 없는 냄새가 진동한다.',
        choices: [
          EventChoice(
            label: '조심스럽게 건넌다',
            outcomeText: '독 웅덩이를 피해 건넜다. 반대편에서 금화를 발견했다.',
            goldChange: config.goldReward,
            hpChange: 0,
          ),
          EventChoice(
            label: '독에 무기를 담근다',
            outcomeText: '무기에 독이 스며든다. 새로운 기술을 터득했다.',
            goldChange: 0,
            hpChange: -5,
            cardRewardId: 'colorless_random',
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 15: 잠든 수호자
      EventRoomData(
        title: '잠든 수호자',
        narrativeText: '거대한 골렘이 문 앞에서 잠들어 있다. 깨우지 않고 지나갈 수 있을까.',
        choices: [
          EventChoice(
            label: '살금살금 지나간다',
            outcomeText: '숨을 죽이고 골렘 옆을 지났다. 그 뒤에서 보물을 발견했다.',
            goldChange: 15,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '골렘을 깨워 도전한다',
            outcomeText: '치열한 싸움 끝에 골렘이 무너졌다. 핵에서 강한 힘이 흘러나온다.',
            goldChange: 0,
            hpChange: -12,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMajorReward,
            },
          ),
        ],
      ),
      // 이벤트 16: 비밀의 연구실
      EventRoomData(
        title: '비밀의 연구실',
        narrativeText: '숨겨진 문 너머로 연구실이 나타난다. 탁자 위에 약병과 도구, 조합법이 놓여 있다.',
        choices: [
          EventChoice(
            label: '약물을 마신다',
            outcomeText: '강렬한 고통과 함께 새로운 힘이 솟구친다. 기술이 성장한다.',
            goldChange: 0,
            hpChange: -8,
            cardRewardId: 'colorless_random',
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '도구를 판다',
            outcomeText: '연구 도구를 챙겨 나중에 팔 수 있을 것이다.',
            goldChange: 20,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '조합법을 연구한다',
            outcomeText: '조합법에서 얻은 지식으로 기존 기술이 날카로워진다.',
            goldChange: 0,
            hpChange: 0,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
              DispositionAxis.harmony: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 17: 버려진 도서관
      EventRoomData(
        title: '버려진 도서관',
        narrativeText: '먼지 쌓인 책장이 끝없이 늘어선 도서관이다. 마법서 한 권이 희미하게 빛나고 있다.',
        choices: [
          EventChoice(
            label: '마법서를 읽는다',
            outcomeText: '금지된 지식이 머리에 쏟아져 들어온다. 고통스럽지만 기술이 성장한다.',
            goldChange: 0,
            hpChange: -3,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '책을 판다',
            outcomeText: '고서적은 비싼 가격에 팔 수 있다. 금화를 챙긴다.',
            goldChange: 15,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 18: 갈라진 바닥
      EventRoomData(
        title: '갈라진 바닥',
        narrativeText: '발밑의 바닥이 갈라져 있다. 아래로 깊은 틈이 보이고, 무언가가 반짝인다.',
        choices: [
          EventChoice(
            label: '뛰어내린다',
            outcomeText: '착지 충격에 몸이 아프지만 보물과 함께 불필요한 짐을 버렸다.',
            goldChange: 25,
            hpChange: -10,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '안전하게 돌아간다',
            outcomeText: '위험을 피하고 안전한 길로 돌아간다. 잠시 쉬며 체력을 회복한다.',
            goldChange: 0,
            hpChange: 5,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
      // 이벤트 19: 잊혀진 대장간
      EventRoomData(
        title: '잊혀진 대장간',
        narrativeText: '꺼지지 않는 화덕이 타오르는 대장간이다. 모루 위에 망치가 놓여 있다.',
        choices: [
          EventChoice(
            label: '카드를 강화한다',
            outcomeText: '대장간의 불꽃으로 기술을 벼린다. 한 단계 성장했다.',
            goldChange: -20,
            hpChange: 0,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '금속을 수집한다',
            outcomeText: '쓸 만한 금속 조각을 주워 금화로 바꿀 수 있다.',
            goldChange: 15,
            hpChange: 0,
          ),
          EventChoice(
            label: '불씨를 가져간다',
            outcomeText: '영원한 불씨의 온기가 몸을 감싼다. 불필요한 기술이 불꽃에 녹아든다.',
            goldChange: 0,
            hpChange: 5,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMinorReward,
            },
          ),
        ],
      ),
    ];
  }

  /// 히든 이벤트 풀 — 조건부 출현 (층/기억/저주).
  static List<EventRoomData> _buildHiddenEventPool(
    EventConfig config,
    DispositionConfig dConfig,
    int floor, {
    int unlockedMemoryCount = 0,
    bool hasCurses = false,
  }) {
    final events = <EventRoomData>[];

    // 히든 1: 차원의 균열 — 3층+, 기억 3개+
    if (floor >= 3 && unlockedMemoryCount >= 3) {
      events.add(EventRoomData(
        title: '차원의 균열',
        narrativeText:
            '공간이 찢어지며 이상한 빛이 새어나온다. 균열 너머로 잊혀진 세계의 단편이 보인다.',
        choices: [
          EventChoice(
            label: '균열을 탐색한다',
            outcomeText: '균열 속에서 고대의 지혜가 흘러들어온다. 기술이 날카로워진다.',
            goldChange: 0,
            hpChange: -5,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '물러선다',
            outcomeText: '균열이 닫히며 바닥에 금화 몇 닢이 남았다.',
            goldChange: config.goldReward,
            hpChange: 0,
          ),
        ],
      ));
    }

    // 히든 2: 잊혀진 제단 (저주 해제/강화) — 저주 활성 시
    if (hasCurses) {
      events.add(EventRoomData(
        title: '잊혀진 제단',
        narrativeText:
            '어둠 속에서 고대 제단이 발견된다. 저주의 기운과 정화의 빛이 공존하고 있다.',
        choices: [
          EventChoice(
            label: '정화의 기도를 올린다',
            outcomeText: '저주의 일부가 풀려난다. 하지만 대가로 생명력이 소모된다.',
            goldChange: 0,
            hpChange: -10,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '제단의 어둠을 흡수한다',
            outcomeText: '어둠의 힘이 금화로 변환된다. 하지만 저주는 더 깊어진다.',
            goldChange: (config.goldReward * 2).round(),
            hpChange: -15,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMajorReward,
            },
          ),
        ],
      ));
    }

    // 히든 3: 시간의 방 — 3층+
    if (floor >= 3) {
      events.add(EventRoomData(
        title: '시간의 방',
        narrativeText:
            '시간이 멈춘 듯한 방이 나타난다. 이곳에서는 기술을 갈고닦거나, 불필요한 것을 버릴 수 있다.',
        choices: [
          EventChoice(
            label: '기술을 단련한다',
            outcomeText: '시간의 흐름 속에서 기존 기술이 한 단계 성장한다.',
            goldChange: 0,
            hpChange: 0,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '불필요한 것을 버린다',
            outcomeText: '필요 없는 기술을 시간의 흐름에 맡긴다. 가벼워진 몸이 치유된다.',
            goldChange: 0,
            hpChange: 5,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMinorReward,
            },
          ),
        ],
      ));
    }

    // 히든 4: 영혼의 거울 — 4층+
    if (floor >= 4) {
      events.add(EventRoomData(
        title: '영혼의 거울',
        narrativeText:
            '거대한 거울이 서 있다. 거울 속 자신이 다른 선택을 한 평행 세계의 모습을 보여준다.',
        choices: [
          EventChoice(
            label: '거울 속 자신과 대면한다',
            outcomeText: '평행 세계의 기술이 스며든다. 새로운 가능성이 열린다.',
            goldChange: 0,
            hpChange: -8,
            cardRewardId: 'colorless_random',
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '거울의 빛을 받아들인다',
            outcomeText: '거울의 빛이 상처를 치유한다.',
            goldChange: 0,
            hpChange: 15,
          ),
        ],
      ));
    }

    // 히든 5: 사신의 문 — 3층+
    if (floor >= 3) {
      events.add(EventRoomData(
        title: '사신의 문',
        narrativeText:
            '검은 문 앞에 해골 장식이 있다. 생과 사의 경계를 넘는 자만이 진정한 힘을 얻는다고 한다.',
        choices: [
          EventChoice(
            label: '문을 연다',
            outcomeText: '사선을 넘어 보물을 손에 넣었다. 하지만 대가가 크다.',
            goldChange: 30,
            hpChange: -20,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '경의를 표한다',
            outcomeText: '문 앞에 고개를 숙이자, 따뜻한 기운이 감싼다.',
            goldChange: 0,
            hpChange: 5,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMediumReward,
            },
          ),
        ],
      ));
    }

    // 히든 6: 환영의 미궁 — 3층+
    if (floor >= 3) {
      events.add(EventRoomData(
        title: '환영의 미궁',
        narrativeText:
            '벽이 끊임없이 변하는 미궁이다. 무엇이 진짜이고 무엇이 환영인지 구분이 어렵다.',
        choices: [
          EventChoice(
            label: '환영을 쫓는다',
            outcomeText: '환영 속에서 새로운 기술을 발견했다. 하지만 정신이 혼미하다.',
            goldChange: 0,
            hpChange: -8,
            cardRewardId: 'colorless_random',
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMinorReward,
            },
          ),
          EventChoice(
            label: '본질을 간파한다',
            outcomeText: '환영의 정체를 꿰뚫어본다. 불필요한 것이 벗겨진다.',
            goldChange: 0,
            hpChange: 0,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMajorReward,
            },
          ),
        ],
      ));
    }

    // 히든 7: 기억의 우물 — 2층+
    if (floor >= 2) {
      events.add(EventRoomData(
        title: '기억의 우물',
        narrativeText:
            '깊은 우물에서 속삭임이 들린다. 잊혀진 기억의 파편이 수면 위를 떠다닌다.',
        choices: [
          EventChoice(
            label: '기억을 건져올린다',
            outcomeText: '과거의 기술이 되살아난다. 하지만 대가로 현재의 기술이 흐려진다.',
            goldChange: 0,
            hpChange: 0,
            cardRewardId: 'colorless_random',
            removeRandomCard: true,
          ),
          EventChoice(
            label: '우물에 금화를 던진다',
            outcomeText: '우물이 빛나며 온기가 퍼진다. 상처가 깨끗이 아문다.',
            goldChange: -10,
            hpChange: 15,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMinorReward,
            },
          ),
        ],
      ));
    }

    // 히든 8: 피의 계약서 — 2층+
    if (floor >= 2) {
      events.add(EventRoomData(
        title: '피의 계약서',
        narrativeText:
            '탁자 위에 핏빛 잉크로 쓰인 계약서가 놓여 있다. 서명하면 큰 힘을 얻을 수 있다고 한다.',
        choices: [
          EventChoice(
            label: '서명한다',
            outcomeText: '피가 끓어오르며 엄청난 힘이 솟구친다. 하지만 영혼이 무거워진다.',
            goldChange: 30,
            hpChange: -15,
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '계약서를 찢는다',
            outcomeText: '계약서가 재로 변한다. 마음이 가벼워지고 의지가 강해진다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.will: dConfig.eventMajorReward,
            },
          ),
        ],
      ));
    }

    // 히든 9: 전이의 회랑 — 4층+
    if (floor >= 4) {
      events.add(EventRoomData(
        title: '전이의 회랑',
        narrativeText:
            '공간이 뒤틀린 회랑이다. 벽을 통과하면 다른 시간대로 이동하는 것 같다.',
        choices: [
          EventChoice(
            label: '과거로 간다',
            outcomeText: '과거의 자신에게서 잊혀진 기술을 전수받는다.',
            goldChange: 0,
            hpChange: -5,
            upgradeRandomCard: true,
            cardRewardId: 'colorless_random',
          ),
          EventChoice(
            label: '현재에 머문다',
            outcomeText: '시공간의 균열에서 떨어진 보물을 주웠다.',
            goldChange: (config.goldReward * 1.5).round(),
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.harmony: dConfig.eventMinorReward,
            },
          ),
        ],
      ));
    }

    // 히든 10: 속삭이는 벽 — 2층+
    if (floor >= 2) {
      events.add(EventRoomData(
        title: '속삭이는 벽',
        narrativeText:
            '벽면에서 수많은 목소리가 속삭인다. 이전 모험가들의 잔류 사념인 듯하다.',
        choices: [
          EventChoice(
            label: '귀를 기울인다',
            outcomeText: '사념 속에서 유용한 정보를 얻었다. 불필요한 기술을 버리는 법을 배운다.',
            goldChange: 0,
            hpChange: 0,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '무시하고 지나간다',
            outcomeText: '목소리를 떨쳐내고 앞으로 나아간다. 투쟁의 의지가 불타오른다.',
            goldChange: 0,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMinorReward,
            },
          ),
        ],
      ));
    }

    // 히든 11: 운명의 바퀴 — 3층+
    if (floor >= 3) {
      events.add(EventRoomData(
        title: '운명의 바퀴',
        narrativeText:
            '거대한 룬 바퀴가 천천히 돌고 있다. 바퀴를 멈추면 운명이 바뀔 것 같다.',
        choices: [
          EventChoice(
            label: '바퀴를 돌린다',
            outcomeText: '바퀴가 멈추며 운명의 힘이 쏟아진다. 무언가 변했다.',
            goldChange: 30,
            hpChange: -15,
            upgradeRandomCard: true,
            removeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.struggle: dConfig.eventMediumReward,
            },
          ),
          EventChoice(
            label: '지켜본다',
            outcomeText: '바퀴의 움직임에서 지혜를 얻는다. 바닥에서 금화를 발견했다.',
            goldChange: 10,
            hpChange: 0,
            dispositionRewards: {
              DispositionAxis.wisdom: dConfig.eventMediumReward,
            },
          ),
        ],
      ));
    }

    // 히든 12: 동반자의 묘지 — 4층+
    if (floor >= 4) {
      events.add(EventRoomData(
        title: '동반자의 묘지',
        narrativeText:
            '이름 모를 모험가들의 묘지가 나타난다. 비석에 새겨진 글귀가 마음을 울린다.',
        choices: [
          EventChoice(
            label: '무덤을 파헤친다',
            outcomeText: '망자의 유품에서 강력한 기술을 발견했다. 하지만 대가가 따른다.',
            goldChange: 0,
            hpChange: -10,
            cardRewardId: 'colorless_random',
            upgradeRandomCard: true,
            dispositionRewards: {
              DispositionAxis.shadow: dConfig.eventMajorReward,
            },
          ),
          EventChoice(
            label: '묵념한다',
            outcomeText: '망자들의 영혼이 감사를 전한다. 따뜻한 기운이 상처를 치유한다.',
            goldChange: 0,
            hpChange: 15,
            dispositionRewards: {
              DispositionAxis.mercy: dConfig.eventMajorReward,
            },
          ),
        ],
      ));
    }

    return events;
  }
}
