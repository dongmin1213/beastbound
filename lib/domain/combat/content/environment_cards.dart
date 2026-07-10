import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 환경 카드 11종 — 층별 6 + 보스 5, base/observed 버전.
class EnvironmentCards {
  EnvironmentCards._();

  // ── 층별 환경 카드 (base) ─────────────────────────────

  /// 천장 낙석 — 1AP, 20 고정 데미지 (관통).
  static const ceilingCollapse = CardData(
    id: 'env_ceiling_collapse',
    name: '천장 낙석',
    type: CardType.skill,
    apCost: 1,
    description: '20 고정 데미지 (방어 무시). 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.fixedDamage, value: 20)],
    targetType: CardTargetType.all,
  );

  /// 늪의 독기 — 1AP, 독 8 부여.
  static const swampMiasma = CardData(
    id: 'env_swamp_miasma',
    name: '늪의 독기',
    type: CardType.skill,
    apCost: 1,
    description: '독 8 부여. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 8)],
    targetType: CardTargetType.all,
  );

  /// 사슬 속박 — 1AP, 약화 2턴 + 취약 2턴.
  static const chainBind = CardData(
    id: 'env_chain_bind',
    name: '사슬 속박',
    type: CardType.skill,
    apCost: 1,
    description: '약화 2턴 + 취약 2턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 2),
      CardEffect(type: CardEffectType.applyVulnerable, value: 2),
    ],
  );

  /// 마력 결정 — 1AP, 이번 턴 AP +2.
  static const manaCrystal = CardData(
    id: 'env_mana_crystal',
    name: '마력 결정',
    type: CardType.skill,
    apCost: 1,
    description: '이번 턴 AP +2. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.apGain, value: 2)],
  );

  /// 제단의 불꽃 — 2AP, 25 데미지 + 화상 5.
  static const altarFlame = CardData(
    id: 'env_altar_flame',
    name: '제단의 불꽃',
    type: CardType.attack,
    apCost: 2,
    damage: 25,
    description: '25 데미지 + 화상 5. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyBurn, value: 5)],
    targetType: CardTargetType.all,
  );

  /// 심연의 균열 — 2AP, 적 최대 HP 15% 데미지.
  static const abyssalRift = CardData(
    id: 'env_abyssal_rift',
    name: '심연의 균열',
    type: CardType.skill,
    apCost: 2,
    description: '적 최대 HP 15% 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.enemyMaxHpPercentDamage, value: 15)],
    targetType: CardTargetType.all,
  );

  // ── 층별 환경 카드 (observed/업그레이드) ──────────────

  static const ceilingCollapsePlus = CardData(
    id: 'env_ceiling_collapse+',
    name: '천장 낙석+',
    type: CardType.skill,
    apCost: 1,
    description: '30 고정 데미지 (방어 무시). 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.fixedDamage, value: 30)],
    targetType: CardTargetType.all,
    upgraded: true,
  );

  static const swampMiasmaPlus = CardData(
    id: 'env_swamp_miasma+',
    name: '늪의 독기+',
    type: CardType.skill,
    apCost: 1,
    description: '독 12 부여. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyPoison, value: 12)],
    targetType: CardTargetType.all,
    upgraded: true,
  );

  static const chainBindPlus = CardData(
    id: 'env_chain_bind+',
    name: '사슬 속박+',
    type: CardType.skill,
    apCost: 1,
    description: '약화 3턴 + 취약 3턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.applyWeak, value: 3),
      CardEffect(type: CardEffectType.applyVulnerable, value: 3),
    ],
    upgraded: true,
  );

  static const manaCrystalPlus = CardData(
    id: 'env_mana_crystal+',
    name: '마력 결정+',
    type: CardType.skill,
    apCost: 0,
    description: '이번 턴 AP +2. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.apGain, value: 2)],
    upgraded: true,
  );

  static const altarFlamePlus = CardData(
    id: 'env_altar_flame+',
    name: '제단의 불꽃+',
    type: CardType.attack,
    apCost: 1,
    damage: 30,
    description: '30 데미지 + 화상 8. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyBurn, value: 8)],
    targetType: CardTargetType.all,
    upgraded: true,
  );

  static const abyssalRiftPlus = CardData(
    id: 'env_abyssal_rift+',
    name: '심연의 균열+',
    type: CardType.skill,
    apCost: 1,
    description: '적 최대 HP 20% 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.enemyMaxHpPercentDamage, value: 20)],
    targetType: CardTargetType.all,
    upgraded: true,
  );

  // ── 보스 전용 환경 카드 (base) ────────────────────────

  /// 염산 웅덩이 — 슬라임 왕, 재생 무효 3턴.
  static const acidPool = CardData(
    id: 'env_acid_pool',
    name: '염산 웅덩이',
    type: CardType.skill,
    apCost: 1,
    description: '재생 무효 3턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.regenNullify, value: 3)],
  );

  /// 거미줄 역이용 — 거미 군주, 적 행동 차단 1턴.
  static const webReversal = CardData(
    id: 'env_web_reversal',
    name: '거미줄 역이용',
    type: CardType.skill,
    apCost: 1,
    description: '적 행동 차단 1턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.stunEnemy, value: 1)],
  );

  /// 함정 기동 — 오크 대장군, 분노 스택 초기화.
  static const trapTrigger = CardData(
    id: 'env_trap_trigger',
    name: '함정 기동',
    type: CardType.skill,
    apCost: 1,
    description: '적 강화 초기화. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.resetEnemyBuff, value: 0)],
  );

  /// 성수 — 뱀파이어 군주, 흡혈 무효 3턴 + 10 데미지.
  static const holyWater = CardData(
    id: 'env_holy_water',
    name: '성수',
    type: CardType.attack,
    apCost: 1,
    damage: 10,
    description: '흡혈 무효 3턴 + 10 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.drainNullify, value: 3)],
  );

  /// 근원의 빛 — 던전 마스터, 현 페이즈 약점 2배.
  static const primordialLight = CardData(
    id: 'env_primordial_light',
    name: '근원의 빛',
    type: CardType.skill,
    apCost: 1,
    description: '현 페이즈 취약 3턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyVulnerable, value: 3)],
  );

  // ── 보스 전용 환경 카드 (observed/업그레이드) ──────────

  static const acidPoolPlus = CardData(
    id: 'env_acid_pool+',
    name: '염산 웅덩이+',
    type: CardType.skill,
    apCost: 0,
    description: '재생 무효 5턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.regenNullify, value: 5)],
    upgraded: true,
  );

  static const webReversalPlus = CardData(
    id: 'env_web_reversal+',
    name: '거미줄 역이용+',
    type: CardType.skill,
    apCost: 0,
    description: '적 행동 차단 2턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.stunEnemy, value: 2)],
    upgraded: true,
  );

  static const trapTriggerPlus = CardData(
    id: 'env_trap_trigger+',
    name: '함정 기동+',
    type: CardType.skill,
    apCost: 0,
    description: '적 강화 초기화 + 약화 2턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [
      CardEffect(type: CardEffectType.resetEnemyBuff, value: 0),
      CardEffect(type: CardEffectType.applyWeak, value: 2),
    ],
    upgraded: true,
  );

  static const holyWaterPlus = CardData(
    id: 'env_holy_water+',
    name: '성수+',
    type: CardType.attack,
    apCost: 0,
    damage: 15,
    description: '흡혈 무효 5턴 + 15 데미지. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.drainNullify, value: 5)],
    upgraded: true,
  );

  static const primordialLightPlus = CardData(
    id: 'env_primordial_light+',
    name: '근원의 빛+',
    type: CardType.skill,
    apCost: 0,
    description: '현 페이즈 취약 5턴. 소진',
    keywords: {CardKeyword.exhaust},
    effects: [CardEffect(type: CardEffectType.applyVulnerable, value: 5)],
    upgraded: true,
  );

  /// 모든 base 환경 카드 11종.
  static const List<CardData> allBase = [
    ceilingCollapse,
    swampMiasma,
    chainBind,
    manaCrystal,
    altarFlame,
    abyssalRift,
    acidPool,
    webReversal,
    trapTrigger,
    holyWater,
    primordialLight,
  ];

  /// 모든 upgraded 환경 카드 11종.
  static const List<CardData> allUpgraded = [
    ceilingCollapsePlus,
    swampMiasmaPlus,
    chainBindPlus,
    manaCrystalPlus,
    altarFlamePlus,
    abyssalRiftPlus,
    acidPoolPlus,
    webReversalPlus,
    trapTriggerPlus,
    holyWaterPlus,
    primordialLightPlus,
  ];
}
