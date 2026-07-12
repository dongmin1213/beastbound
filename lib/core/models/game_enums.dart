/// 5개 행동 유형 — 전투/기세/서사/오디오 크로스커팅 공유 타입.
enum ActionType {
  attack,
  defend,
  observe,
  environment,
  special;

  String get displayName => switch (this) {
        ActionType.attack => '공격',
        ActionType.defend => '방어',
        ActionType.observe => '관찰',
        ActionType.environment => '환경활용',
        ActionType.special => '특수',
      };
}

/// 8개 방 유형 — 던전 내 방의 종류를 정의.
enum RoomType {
  combat,
  elite,
  event,
  mystery,
  shop,
  npc,
  rest,
  boss;
}

/// 6개 아이템 유형 — 인벤토리 아이템 분류.
enum ItemType {
  blessing,
  curse,
  supply,
  relic,
  memoryEcho,
  card,
  cardRemoval;
}

/// 4단계 희귀도 — 아이템/축복 등급 분류.
enum Rarity {
  common,
  rare,
  legendary,
  cursed;
}

/// 5층 테마 — 던전 각 층의 시각/서사 테마.
enum FloorTheme {
  ruins,
  cavern,
  prison,
  sanctuary,
  abyss;
}

/// 서사 레이어 — 텍스트 콘텐츠의 깊이 단계.
enum NarrativeLayer {
  l1,
  l2,
  l3;
}

/// 런 유형 — 첫 번째 런 vs 반복 런 구분.
enum RunType {
  first,
  repeat;
}

/// 상호작용 결과 등급 — 전투 행동의 효과 판정.
enum ActionResult {
  effective,
  neutral,
  ineffective,
}

/// 기억 카테고리 — 기억 조각의 분류.
enum MemoryCategory {
  origin,
  loss,
  bond,
  cycle,
  none;
}

/// 3개 카드 타입 — 공격/스킬/파워.
enum CardType {
  attack,
  skill,
  power;

  String get displayName => switch (this) {
        CardType.attack => '공격',
        CardType.skill => '스킬',
        CardType.power => '파워',
      };
}

/// 4개 카드 키워드 — 특수 행동 수식어.
enum CardKeyword {
  exhaust,
  innate,
  ethereal,
  retain;

  String get displayName => switch (this) {
        CardKeyword.exhaust => '소진',
        CardKeyword.innate => '선천',
        CardKeyword.ethereal => '영체',
        CardKeyword.retain => '유지',
      };

  /// 키워드 설명 — 카드 상세보기에서 표시.
  String get description => switch (this) {
        CardKeyword.exhaust => '사용 후 소멸하여 이번 전투에서 다시 뽑을 수 없다.',
        CardKeyword.innate => '전투 시작 시 항상 첫 손패에 포함된다.',
        CardKeyword.ethereal => '턴 종료 시 사용하지 않으면 소멸한다.',
        CardKeyword.retain => '턴 종료 시 버려지지 않고 손패에 남는다.',
      };
}

/// 8개 상태 효과 타입 — 버프/디버프.
enum StatusEffectType {
  poison,
  burn,
  weak,
  vulnerable,
  strength,
  dexterity,
  thorn,
  regenerate;

  bool get isDebuff =>
      this == poison || this == burn || this == weak || this == vulnerable;

  bool get isBuff => !isDebuff;

  String get displayName => switch (this) {
        StatusEffectType.poison => '독',
        StatusEffectType.burn => '화상',
        StatusEffectType.weak => '약화',
        StatusEffectType.vulnerable => '취약',
        StatusEffectType.strength => '힘',
        StatusEffectType.dexterity => '민첩',
        StatusEffectType.thorn => '가시',
        StatusEffectType.regenerate => '재생',
      };

  /// 상태효과 상세 설명 — 도움말 팝업에 표시.
  String get description => switch (this) {
        StatusEffectType.poison => '매 턴 종료 시 중첩 수만큼 피해를 받고, 중첩이 1 감소합니다.',
        StatusEffectType.burn => '매 턴 종료 시 중첩 수만큼 피해를 받고, 중첩이 절반으로 줄어듭니다.',
        StatusEffectType.weak => '공격 데미지가 25% 감소합니다.',
        StatusEffectType.vulnerable => '받는 데미지가 50% 증가합니다.',
        StatusEffectType.strength => '공격 카드의 데미지가 중첩당 +1 증가합니다.',
        StatusEffectType.dexterity => '방어 카드의 블록이 중첩당 +1 증가합니다.',
        StatusEffectType.thorn => '피격 시 공격자에게 중첩 수만큼 피해를 줍니다.',
        StatusEffectType.regenerate => '매 턴 종료 시 중첩 수만큼 HP를 회복하고, 중첩이 1 감소합니다.',
      };
}

/// 카드 효과 유형 — CardEffect.type에 사용.
enum CardEffectType {
  absorbStrength,
  adaptiveDamage,
  allTypesApBonus,
  apGain,
  apPenaltyNextTurn,
  applyBurn,
  applyPoison,
  applyVulnerable,
  applyWeak,
  blockPerCardPlayed,
  blockPerTurnStart,
  blockPerTurnStartConditional,
  blockRetain,
  block,
  boostLowestStat,
  cleanse,
  coinFlip,
  conditionalBlock,
  conditionalDamage,
  copyLastAttack,
  cycleHand,
  damage,
  damageEqualLostHp,
  damagePerHandCard,
  discardAndDraw,
  doubleNextAttack,
  drainNullify,
  draw,
  equalizeHpBlock,
  executeHpPercent,
  exhaustAndDraw,
  fixedDamage,
  gainDexterity,
  gainRegenerate,
  gainStrength,
  gainThorn,
  generateAttackPerTurn,
  generateRandomCard,
  heal,
  healOnKill,
  highMomentumBonus,
  hpPercentDamage,
  enemyMaxHpPercentDamage,
  ignoreBlock,
  immuneThisTurn,
  mimicEnemyDamage,
  momentumGain,
  multiHit,
  nothing,
  playRestriction,
  poisonMultiplierDamage,
  randomDamage,
  randomDebuffs,
  regenNullify,
  replayLastCard,
  resetEnemyBuff,
  retribution,
  retrieveFromDiscard,
  retrieveRandomPerTurn,
  revealIntent,
  selfDamage,
  selfDamagePerTurn,
  setFleeGuaranteed,
  setPoisonPerTurn,
  splitHpToBlock,
  sprintExhaust,
  strengthPerTurn,
  stunEnemy,
  thornMultiplierDamage,
  transformHandPerTurn,

  // ── 콘텐츠 확장 신규 효과 ──
  /// 데미지의 N% HP 회복 (전사 피의일격, 사신 생명약탈).
  lifesteal,

  /// 적 독 스택 전부 즉시 데미지로 전환 (암살자 독 폭발).
  poisonBurst,

  /// N% 확률 피격 회피 (암살자 그림자걸음/어둠의망토).
  dodgeChance,

  /// 이번 턴 Attack 사용 수 × N HP 회복 (전사 전장의고동).
  healPerAttackPlayed,

  /// 잃은 HP의 N% 매 턴 블록 (전사 철의의지).
  lostHpToBlockPerTurn,

  /// 적 HP ≤50%: value 데미지, else duration 데미지 (전사 처형).
  conditionalDamageEnemyHp,

  /// 소진 파일 카드 수 × N 데미지 (방랑자 노련한일격).
  damagePerExhaust,

  /// 현재 손패 수 × N 추가 블록 (현자 마력방벽).
  handSizeBlock,

  /// 이번 턴 Skill 사용 수 × N 데미지 (현자 마력환류).
  skillCountDamage,

  /// 턴 종료 시 남은 AP × N 블록 (무색 절약).
  remainingApBlock,

  /// 소진 파일에서 N장 손패 복귀 (무색 시간되감기).
  retrieveFromExhaust,

  /// 피격 시 N% 확률 데미지 반사 (환술사 거울의미로).
  reflectDamageChance,

  /// 힘 ↔ 민첩 교환 (조율사 흐름전환).
  swapStrDex,

  /// (힘 + 민첩) 합산 데미지, condition으로 추가 스탯 (조율사).
  statSumDamage,

  /// 매 턴 HP N 회복 Power (무색 저력).
  healPerTurn,

  /// 매 턴 드로우 +N Power (현자 지식의탑).
  drawPerTurn,

  // ── Phase 3-B 신규 효과 ──

  /// 모든 Attack 카드에 N% 흡혈 부여 Power (전사 광전사).
  lifestealOnAllAttacks,

  // momentumGain은 이미 위에 정의됨 (직접 기세 N 획득).

  /// 조건부 매 턴 HP N 회복 Power (전사 전투의고동: condition 'strengthGte2').
  healPerTurnConditional,

  /// 초과(오버킬) 데미지의 N% HP 회복 (성자 응보).
  excessDamageLifesteal,

  /// 다음 Skill 카드 AP N 감소 (현자 마력흡수).
  nextSkillApDiscount,

  /// 관통 초과 데미지의 N%를 블록으로 전환 Power (현자 마나보호막).
  overflowToBlock,

  /// 사용 후 N턴 쿨다운 — Exhaust 대신 재사용 제한 (암살자 은신).
  cooldownAfterUse,

  /// 회피 성공 시 기세 N 획득 (암살자 그림자걸음).
  momentumGainOnDodge,

  /// 적 독 스택 N당 받는 데미지 -1 Power (암살자 독의보호). condition으로 최대값.
  poisonDamageReduction,

  /// 다음 N회 피격 무효 (암살자 그림자도약).
  immuneNextHits,

  /// 블록 ≥ condition 시 피해 -N Power (수호자 철벽의의지).
  damageReductionWhenBlock,

  /// 피격 턴 종료 시 HP N 회복 Power (방랑자 본능).
  healOnDamageTaken,

  /// 반사 성공 시 HP N 회복 (환술사 거울의미로).
  healOnReflect,

  /// 다음 피격 데미지 N% 감소 (환술사 환영의분신).
  nextHitDamageReduction,

  // ── Phase 4: 2차 전직 신규 효과 ──

  /// 독 효과 N% 증폭 Power (그림자군주 독의지배).
  poisonEffectivenessBoost,

  /// 블록 100% 유지 (철벽성주 절대방벽/수호자의맹세).
  blockRetainFull,

  /// 이번 턴 받는 데미지의 N% 반사 (철벽성주 반사의벽).
  reflectDamagePercent,

  /// 현재 블록의 N% 데미지 + 블록 유지 (철벽성주 철벽돌진).
  blockToDamageKeepBlock,

  /// 매 턴 블록 +N Power (철벽성주 가시요새/암흑기사 암흑방패).
  blockPerTurnFixed,

  /// 블록 ≥ N일 때 받는 데미지 -value (철벽성주 수호자의맹세 확장).
  damageReductionAtBlock,

  /// 랜덤 버프 1개 부여 (운명의여행자 운명의일격).
  randomBuff,

  /// 소진 파일에서 N장 복원 (운명의여행자 시간역행). retrieveFromExhaust의 별칭.
  retrieveFromExhaustPile,

  /// 소진된 카드 수 × N 데미지 (운명의여행자 행운폭발).
  exhaustPileCountDamage,

  /// 매 턴 랜덤 카드 생성 + HP N 회복 Power (운명의여행자 운명조율).
  generateRandomCardAndHealPerTurn,

  /// 적 HP ≤ N%: 즉사 (명계왕 사신의대낫).
  executeHpPercentInstantKill,

  /// 준 데미지의 N% HP 회복 (흡혈 변형, 자해 포함).
  lifestealWithSelfDamage,

  /// 잃은 HP × N배 데미지 (명계왕 저승의심판). damageEqualLostHp의 배율 변형.
  lostHpMultiplierDamage,

  /// HP < N%일 때 블록+치유 (명계왕 불멸).
  emergencyBlockAndHeal,

  /// 마지막 Attack 카드 복제 (차원술사 차원폭풍).
  copyLastAttackToHand,

  /// 마지막 카드 N회 복제 (차원술사 완벽한복제).
  copyLastCardMultiple,

  /// 모든 Attack에 관통(ignoreBlock) 부여 Power (마검사 마검각성).
  allAttackPiercing,

  /// 손패 수 × N 추가 블록 (마검사 마력방패). handSizeBlock의 별칭.
  handCountBlock,

  /// 매 턴 드로우 +N Power (대현자 대마법진). drawPerTurn의 확장.
  drawPerTurnAndSkillDiscount,

  /// 모든 Skill AP -N Power (대현자 대마법진).
  allSkillApDiscount,

  /// 모든 Attack에 N% 흡혈 부여 Power (성기사 성전사의맹세).
  lifestealOnAllAttacksPercent,

  /// 준 데미지의 N% HP 회복 (성기사 심판의일격).
  healPercentOfDamageDealt,

  /// 다음 Attack 데미지 +N% (흑마법사 흑마법증폭).
  nextAttackDamageBoost,

  /// 매 턴 독 N + 드로우 +1 Power (흑마법사 암흑의힘).
  poisonPerTurnAndDraw,

  /// 블록의 N% 데미지 + 블록 N% 유지 (암흑기사 반격의일섬).
  blockToDamagePartialRetain,

  /// 블록 유지 N% + 힘 +value Power (암흑기사 암흑기사의맹세).
  blockRetainPercentAndStrength,

  /// 적 독 → 데미지+치유 전환 (심판자 독을삼키는빛).
  convertPoisonToDamageAndHeal,

  /// 정화 시 적에게 N 데미지 Power (심판자 절대정의).
  damageOnCleanse,

  /// 다회 관통 공격 (마검사 연쇄마검).
  multiHitPiercing,

  /// (힘+민첩+가시) × N 데미지 (만물일체 완전한일격).
  allStatsDamage,

  /// 매 턴 최저 스탯 +N Power (만물일체 만물의조화).
  boostLowestStatPerTurn,

  /// 이번 턴 사용 카드 수 × N 데미지 (만물일체 공명폭발).
  cardsPlayedDamage,

  /// HP와 블록을 균등화 (만물일체 절대균형).
  equalizeHpAndBlock,

  /// 의도 공개 + 드로우 (심판자 심판자의눈).
  revealIntentAndDraw,

  /// 매 턴 독 N 부여 + 회피 N% Power (그림자군주 그림자왕좌).
  poisonPerTurnAndDodge,

  /// 독 스택 × N 데미지 (그림자군주 암살). poisonMultiplierDamage의 변형.
  poisonStackMultiplierDamage,

  /// 다회 공격 + 각 히트마다 독 N (그림자군주 그림자폭풍).
  multiHitWithPoison,
}

/// 카드 타겟 유형 — 단일/전체 대상.
enum CardTargetType {
  /// 단일 대상 (기본값).
  single,

  /// 전체 대상 (AoE).
  all;
}

/// 전투 결과 — 승리/패배/도주.
enum CombatOutcome {
  victory,
  defeat,
  fled;
}

/// 5개 게임 자원 — 게임 내 자원 유형.
enum ResourceType {
  gold,
  hp,
  momentum,
  soul,
  memoryFragment;

  /// 런 간 영속 여부. soul과 memoryFragment만 영속.
  bool get persistent => this == soul || this == memoryFragment;
}
