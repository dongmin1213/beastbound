import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 무색 카드 — 모든 직업이 보상으로 획득 가능. 28종.
class ColorlessCards {
  ColorlessCards._();

  // ── 1. 새출발 ──
  static const freshStart = CardData(
    id: 'colorless_fresh_start',
    name: '새출발',
    type: CardType.skill,
    apCost: 1,
    description: '손패 전부 버리고 5장 드로우. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.discardAndDraw, value: 5)],
  );

  // ── 2. 위협 ──
  static const threaten = CardData(
    id: 'colorless_threaten',
    name: '위협',
    type: CardType.skill,
    apCost: 0,
    description: '적 약화 1턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1)],
  );

  // ── 3. 선제공격 ──
  static const preemptiveStrike = CardData(
    id: 'colorless_preemptive',
    name: '선제공격',
    type: CardType.attack,
    apCost: 0,
    damage: 3,
    description: '3 데미지',
    keywords: {CardKeyword.innate},
  );

  // ── 4. 도주 준비 ──
  static const fleePrepare = CardData(
    id: 'colorless_flee_prepare',
    name: '도주 준비',
    type: CardType.skill,
    apCost: 1,
    block: 4,
    description: '블록 4 + 도주 성공률 100%',
    keywords: {CardKeyword.retain},
    effects: [CardEffect(type: CardEffectType.setFleeGuaranteed, value: 0)],
  );

  // ── 5. 관찰 ──
  static const observe = CardData(
    id: 'colorless_observe',
    name: '관찰',
    type: CardType.skill,
    apCost: 1,
    block: 5,
    description: '블록 5 + 1장 드로우 + 환경 카드 해금',
    effects: [
      CardEffect(type: CardEffectType.draw, value: 1),
      CardEffect(type: CardEffectType.revealIntent, value: 0),
    ],
  );

  // ── 6. 약점 간파 ──
  static const exposeWeakness = CardData(
    id: 'colorless_expose_weakness',
    name: '약점 간파',
    type: CardType.skill,
    apCost: 1,
    description: '적 취약 2턴',
    effects: [CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 2)],
  );

  // ── 7. 집중 타격 ──
  static const focusedStrike = CardData(
    id: 'colorless_focused_strike',
    name: '집중 타격',
    type: CardType.attack,
    apCost: 2,
    damage: 20,
    description: '20 데미지. 소진',
    keywords: {CardKeyword.exhaust},
  );

  // ── 8. 전력 질주 ──
  static const sprint = CardData(
    id: 'colorless_sprint',
    name: '전력 질주',
    type: CardType.skill,
    apCost: 0,
    description: 'AP +2, 턴 종료 시 손패 소진',
    effects: [CardEffect(type: CardEffectType.sprintExhaust, value: 2)],
  );

  // ── 9. 통찰 ──
  static const insight = CardData(
    id: 'colorless_insight',
    name: '통찰',
    type: CardType.skill,
    apCost: 0,
    description: '2장 드로우',
    effects: [CardEffect(type: CardEffectType.draw, value: 2)],
  );

  // ── 10. 연막 ──
  static const smokeScreen = CardData(
    id: 'colorless_smoke_screen',
    name: '연막',
    type: CardType.skill,
    apCost: 1,
    block: 10,
    description: '블록 10 + 적 약화 1턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1)],
  );

  // ── 11. 치명타 ──
  static const criticalStrike = CardData(
    id: 'colorless_critical_strike',
    name: '치명타',
    type: CardType.attack,
    apCost: 1,
    damage: 12,
    description: '12 데미지. 기세 High 시 24',
    effects: [CardEffect(type: CardEffectType.highMomentumBonus, value: 0)],
  );

  // ── 12. 기세 충전 ──
  static const momentumCharge = CardData(
    id: 'colorless_momentum_charge',
    name: '기세 충전',
    type: CardType.skill,
    apCost: 1,
    description: '기세 +20. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.momentumGain, value: 20)],
  );

  // ── 13. 환경 폭발 ──
  static const environmentExplosion = CardData(
    id: 'colorless_environment_explosion',
    name: '환경 폭발',
    type: CardType.attack,
    apCost: 2,
    damage: 25,
    description: '25 데미지 (관통). 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  // ── 14. 독 항아리 ──
  static const poisonJar = CardData(
    id: 'colorless_poison_jar',
    name: '독 항아리',
    type: CardType.skill,
    apCost: 1,
    description: '독 5 부여. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 5)],
  );

  // ── 15. 흡수 ──
  static const absorb = CardData(
    id: 'colorless_absorb',
    name: '흡수',
    type: CardType.skill,
    apCost: 1,
    description: 'HP 6 회복',
    effects: [CardEffect(type: CardEffectType.heal, value: 6)],
  );

  // ── 16. 위협 사격 ──
  static const threateningShot = CardData(
    id: 'colorless_threatening_shot',
    name: '위협 사격',
    type: CardType.attack,
    apCost: 1,
    damage: 6,
    description: '6 데미지 + 적 약화 1턴',
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1)],
  );

  // ── 17. 이중타격 ──
  static const doubleStrike = CardData(
    id: 'colorless_double_strike',
    name: '이중타격',
    type: CardType.attack,
    apCost: 1,
    description: '4 데미지 × 2회',
    effects: [CardEffect(type: CardEffectType.multiHit, value: 4, duration: 2)],
  );

  // ── 18. 인내 ──
  static const patience = CardData(
    id: 'colorless_patience',
    name: '인내',
    type: CardType.skill,
    apCost: 0,
    block: 3,
    description: '블록 3',
    keywords: {CardKeyword.retain},
  );

  // ── 19. 속임수 ──
  static const trickery = CardData(
    id: 'colorless_trickery',
    name: '속임수',
    type: CardType.skill,
    apCost: 0,
    description: '손패 1장 소진 → 2장 드로우',
    effects: [CardEffect(type: CardEffectType.exhaustAndDraw, value: 2)],
  );

  // ── 20. 최후의 발악 ──
  static const lastStand = CardData(
    id: 'colorless_last_stand',
    name: '최후의 발악',
    type: CardType.attack,
    apCost: 1,
    description: '현재 HP 10% 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.hpPercentDamage, value: 10)],
  );

  // ── 21. 저력 ──
  static const endurance = CardData(
    id: 'colorless_endurance',
    name: '저력',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 HP 2 회복',
    effects: [CardEffect(type: CardEffectType.healPerTurn, value: 2)],
  );

  // ── 22. 결전 ──
  static const finalBattle = CardData(
    id: 'colorless_final_battle',
    name: '결전',
    type: CardType.attack,
    apCost: 2,
    description: '8 데미지 × 3회. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.multiHit, value: 8, duration: 3)],
  );

  // ── 23. 임기응변 ──
  static const improvise = CardData(
    id: 'colorless_improvise',
    name: '임기응변',
    type: CardType.skill,
    apCost: 0,
    block: 4,
    description: '블록 4 + 1장 드로우',
    effects: [CardEffect(type: CardEffectType.draw, value: 1)],
  );

  // ── 24. 약자의 분노 ──
  static const wrathOfWeak = CardData(
    id: 'colorless_wrath_of_weak',
    name: '약자의 분노',
    type: CardType.attack,
    apCost: 1,
    description: 'HP ≤50%: 20 데미지, 아니면 8',
    effects: [
      CardEffect(
        type: CardEffectType.conditionalDamage,
        value: 20,
        duration: 8,
        condition: 'lowHp',
      ),
    ],
  );

  // ── 25. 절약 ──
  static const thrift = CardData(
    id: 'colorless_thrift',
    name: '절약',
    type: CardType.skill,
    apCost: 0,
    description: '턴 종료 시 남은 AP × 5 블록',
    effects: [CardEffect(type: CardEffectType.remainingApBlock, value: 5)],
  );

  // ── 26. 수집가 ──
  static const collector = CardData(
    id: 'colorless_collector',
    name: '수집가',
    type: CardType.skill,
    apCost: 1,
    description: '2장 드로우. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.draw, value: 2)],
  );

  // ── 27. 과감한 도박 ──
  static const boldGamble = CardData(
    id: 'colorless_bold_gamble',
    name: '과감한 도박',
    type: CardType.attack,
    apCost: 1,
    description: '5~30 랜덤 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.randomDamage, value: 5, duration: 30)],
  );

  // ── 28. 시간 되감기 ──
  static const timeRewind = CardData(
    id: 'colorless_time_rewind',
    name: '시간 되감기',
    type: CardType.skill,
    apCost: 2,
    description: '소진 파일에서 1장 손패 복귀. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.retrieveFromExhaust, value: 1)],
  );

  // ── 29. 소용돌이 (소울 해금) ──
  static const whirlwind = CardData(
    id: 'whirlwind',
    name: '소용돌이',
    type: CardType.attack,
    apCost: 2,
    description: '전체 적에게 6 데미지 × 3회.',
    effects: [CardEffect(type: CardEffectType.multiHit, value: 6, duration: 3)],
  );

  // ── 30. 명상 (소울 해금) ──
  static const meditation = CardData(
    id: 'meditation',
    name: '명상',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 기세 +15 + 1장 드로우.',
    effects: [
      CardEffect(type: CardEffectType.momentumGain, value: 15),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  /// 기본 무색 카드 28장 (소울 해금 카드 미포함).
  static const List<CardData> base = [
    freshStart,
    threaten,
    preemptiveStrike,
    fleePrepare,
    observe,
    exposeWeakness,
    focusedStrike,
    sprint,
    insight,
    smokeScreen,
    criticalStrike,
    momentumCharge,
    environmentExplosion,
    poisonJar,
    absorb,
    threateningShot,
    doubleStrike,
    patience,
    trickery,
    lastStand,
    endurance,
    finalBattle,
    improvise,
    wrathOfWeak,
    thrift,
    collector,
    boldGamble,
    timeRewind,
  ];

  /// 소울 해금 전용 카드.
  static const List<CardData> soulLocked = [
    whirlwind,
    meditation,
  ];

  /// 전체 30장 목록 (소울 해금 카드 포함 — CardPool 인덱스/세이브 복원용).
  static const List<CardData> all = [
    ...base,
    ...soulLocked,
  ];

  // ── 업그레이드 버전 ──

  static const freshStartPlus = CardData(
    id: 'colorless_fresh_start+',
    name: '새출발+',
    type: CardType.skill,
    apCost: 1,
    description: '손패 전부 버리고 7장 드로우. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.discardAndDraw, value: 7)],
  );

  static const threatenPlus = CardData(
    id: 'colorless_threaten+',
    name: '위협+',
    type: CardType.skill,
    apCost: 0,
    description: '적 약화 2턴. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 2)],
  );

  static const preemptiveStrikePlus = CardData(
    id: 'colorless_preemptive+',
    name: '선제공격+',
    type: CardType.attack,
    apCost: 0,
    damage: 5,
    description: '5 데미지',
    upgraded: true,
    keywords: {CardKeyword.innate},
  );

  static const fleePreparePlus = CardData(
    id: 'colorless_flee_prepare+',
    name: '도주 준비+',
    type: CardType.skill,
    apCost: 1,
    block: 6,
    description: '블록 6 + 도주 성공률 100% + 1장 드로우',
    upgraded: true,
    keywords: {CardKeyword.retain},
    effects: [
      CardEffect(type: CardEffectType.setFleeGuaranteed, value: 0),
      CardEffect(type: CardEffectType.draw, value: 1),
    ],
  );

  static const observePlus = CardData(
    id: 'colorless_observe+',
    name: '관찰+',
    type: CardType.skill,
    apCost: 1,
    block: 8,
    description: '블록 8 + 2장 드로우 + 환경 카드 해금',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.draw, value: 2),
      CardEffect(type: CardEffectType.revealIntent, value: 0),
    ],
  );

  static const exposeWeaknessPlus = CardData(
    id: 'colorless_expose_weakness+',
    name: '약점 간파+',
    type: CardType.skill,
    apCost: 1,
    description: '적 취약 3턴',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyVulnerable, value: 1, duration: 3)],
  );

  static const focusedStrikePlus = CardData(
    id: 'colorless_focused_strike+',
    name: '집중 타격+',
    type: CardType.attack,
    apCost: 2,
    damage: 28,
    description: '28 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
  );

  static const sprintPlus = CardData(
    id: 'colorless_sprint+',
    name: '전력 질주+',
    type: CardType.skill,
    apCost: 0,
    description: 'AP +3, 턴 종료 시 손패 소진',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.sprintExhaust, value: 3)],
  );

  static const insightPlus = CardData(
    id: 'colorless_insight+',
    name: '통찰+',
    type: CardType.skill,
    apCost: 0,
    description: '3장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.draw, value: 3)],
  );

  static const smokeScreenPlus = CardData(
    id: 'colorless_smoke_screen+',
    name: '연막+',
    type: CardType.skill,
    apCost: 1,
    block: 15,
    description: '블록 15 + 적 약화 1턴. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1)],
  );

  static const criticalStrikePlus = CardData(
    id: 'colorless_critical_strike+',
    name: '치명타+',
    type: CardType.attack,
    apCost: 1,
    damage: 18,
    description: '18 데미지. 기세 High 시 36',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.highMomentumBonus, value: 0)],
  );

  static const momentumChargePlus = CardData(
    id: 'colorless_momentum_charge+',
    name: '기세 충전+',
    type: CardType.skill,
    apCost: 1,
    description: '기세 +30. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.momentumGain, value: 30)],
  );

  static const environmentExplosionPlus = CardData(
    id: 'colorless_environment_explosion+',
    name: '환경 폭발+',
    type: CardType.attack,
    apCost: 2,
    damage: 35,
    description: '35 데미지 (관통). 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.ignoreBlock, value: 0)],
  );

  static const poisonJarPlus = CardData(
    id: 'colorless_poison_jar+',
    name: '독 항아리+',
    type: CardType.skill,
    apCost: 1,
    description: '독 8 부여. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 8)],
  );

  static const absorbPlus = CardData(
    id: 'colorless_absorb+',
    name: '흡수+',
    type: CardType.skill,
    apCost: 1,
    description: 'HP 10 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.heal, value: 10)],
  );

  static const threateningShotPlus = CardData(
    id: 'colorless_threatening_shot+',
    name: '위협 사격+',
    type: CardType.attack,
    apCost: 1,
    damage: 9,
    description: '9 데미지 + 적 약화 1턴',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.applyWeak, value: 1, duration: 1)],
  );

  static const doubleStrikePlus = CardData(
    id: 'colorless_double_strike+',
    name: '이중타격+',
    type: CardType.attack,
    apCost: 1,
    description: '6 데미지 × 2회',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHit, value: 6, duration: 2)],
  );

  static const patiencePlus = CardData(
    id: 'colorless_patience+',
    name: '인내+',
    type: CardType.skill,
    apCost: 0,
    block: 5,
    description: '블록 5',
    upgraded: true,
    keywords: {CardKeyword.retain},
  );

  static const trickeryPlus = CardData(
    id: 'colorless_trickery+',
    name: '속임수+',
    type: CardType.skill,
    apCost: 0,
    description: '손패 1장 소진 → 3장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.exhaustAndDraw, value: 3)],
  );

  static const lastStandPlus = CardData(
    id: 'colorless_last_stand+',
    name: '최후의 발악+',
    type: CardType.attack,
    apCost: 1,
    description: '현재 HP 15% 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.hpPercentDamage, value: 15)],
  );

  static const endurancePlus = CardData(
    id: 'colorless_endurance+',
    name: '저력+',
    type: CardType.power,
    apCost: 1,
    description: '매 턴 HP 3 회복',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.healPerTurn, value: 3)],
  );

  static const finalBattlePlus = CardData(
    id: 'colorless_final_battle+',
    name: '결전+',
    type: CardType.attack,
    apCost: 2,
    description: '10 데미지 × 3회. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.multiHit, value: 10, duration: 3)],
  );

  static const improvisePlus = CardData(
    id: 'colorless_improvise+',
    name: '임기응변+',
    type: CardType.skill,
    apCost: 0,
    block: 6,
    description: '블록 6 + 2장 드로우',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.draw, value: 2)],
  );

  static const wrathOfWeakPlus = CardData(
    id: 'colorless_wrath_of_weak+',
    name: '약자의 분노+',
    type: CardType.attack,
    apCost: 1,
    description: 'HP ≤50%: 25 데미지, 아니면 10',
    upgraded: true,
    effects: [
      CardEffect(
        type: CardEffectType.conditionalDamage,
        value: 25,
        duration: 10,
        condition: 'lowHp',
      ),
    ],
  );

  static const thriftPlus = CardData(
    id: 'colorless_thrift+',
    name: '절약+',
    type: CardType.skill,
    apCost: 0,
    description: '턴 종료 시 남은 AP × 7 블록',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.remainingApBlock, value: 7)],
  );

  static const collectorPlus = CardData(
    id: 'colorless_collector+',
    name: '수집가+',
    type: CardType.skill,
    apCost: 1,
    description: '3장 드로우. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.draw, value: 3)],
  );

  static const boldGamblePlus = CardData(
    id: 'colorless_bold_gamble+',
    name: '과감한 도박+',
    type: CardType.attack,
    apCost: 1,
    description: '8~35 랜덤 데미지. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.randomDamage, value: 8, duration: 35)],
  );

  static const timeRewindPlus = CardData(
    id: 'colorless_time_rewind+',
    name: '시간 되감기+',
    type: CardType.skill,
    apCost: 2,
    description: '소진 파일에서 2장 손패 복귀. 소진',
    upgraded: true,
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.retrieveFromExhaust, value: 2)],
  );

  static const whirlwindPlus = CardData(
    id: 'whirlwind+',
    name: '소용돌이+',
    type: CardType.attack,
    apCost: 2,
    description: '전체 적에게 8 데미지 × 3회.',
    upgraded: true,
    effects: [CardEffect(type: CardEffectType.multiHit, value: 8, duration: 3)],
  );

  static const meditationPlus = CardData(
    id: 'meditation+',
    name: '명상+',
    type: CardType.skill,
    apCost: 1,
    block: 12,
    description: '블록 12 + 기세 +20 + 2장 드로우.',
    upgraded: true,
    effects: [
      CardEffect(type: CardEffectType.momentumGain, value: 20),
      CardEffect(type: CardEffectType.draw, value: 2),
    ],
  );
}
