# 카드 레퍼런스

카드 시스템 + 무색 30종 + 환경 11종. 직업 카드는 `JOBS.md` 참조.

---

## 총괄 요약

| 구분 | 종수 | 업그레이드 포함 |
|------|------|----------------|
| 공통 시작 | 7 (타격×3 + 방어×2 + 경계×1 + 기합×1) | 14 |
| 기본 직업 (6종) | 91 | 182 |
| 히든 직업 (3종) | 43 | 86 |
| 2차 전직 상위직 (9 × 5) | 45 | 90 |
| 2차 전직 조합직 (5 × 5) | 25 | 50 |
| 무색 | 30 | 60 |
| 환경 (일반 6 + 보스 5) | 11 | 22 |
| **합계** | **252종** | **504 버전** |

직업당 시작 5장 + 보상 9~11장 = 14~16장. 시작 덱: 공통 7장으로 시작 → 직업 분화 시 직업 5장 추가 = 12장.
분화 전 획득한 카드(상점/보상/이벤트)는 분화 시 보존됨 (starter_ 접두사 카드만 교체).

---

## 카드 구조

```dart
CardData {
  id, name, jobId?, type(attack/skill/power),
  apCost, damage?, block?, description,
  upgraded, keywords(Set), effects(List<CardEffect>)
}
CardEffect { type(CardEffectType), value, condition?, duration? }
```

---

## 카드 타입 (3종)

| 타입 | 설명 | 기세 보너스 |
|------|------|-----------|
| **Attack** (공격) | 데미지 딜링 | 타입 전환 시 +12 |
| **Skill** (스킬) | 유틸리티/방어 | 타입 전환 시 +12 |
| **Power** (파워) | 영구 버프 (전투 동안) | 타입 전환 시 +12 |

---

## 카드 키워드 (4종)

| 키워드 | 효과 |
|--------|------|
| **Exhaust** (소진) | 사용 후 이번 전투에서 제거 |
| **Innate** (선천) | 항상 첫 턴 손패에 포함 |
| **Ethereal** (영체) | 턴 종료 시 미사용 시 소진 |
| **Retain** (유지) | 턴 종료 시 손패에 유지 |

---

## AP (행동 포인트)

| 기세 티어 | AP | 체감 |
|-----------|-----|------|
| Low (0~29) | 2 | 핍박 — 카드 2장만 가능 |
| Mid (30~79) | 3 | 기본 — 2~3장, 전략적 선택 |
| High (80~100) | 4 | 파워 — 3~4장, 콤보 가능 |

---

## 연쇄 보너스 (Chain Bonus)

공격(Attack) 카드를 연속으로 사용하면 연쇄 카운터 증가. 스킬/파워 카드를 사이에 끼면 연쇄 끊김.

| 연쇄 | 데미지 보너스 | 추가 효과 |
|------|-------------|----------|
| 2연쇄 | **+20%** | 1장 드로우 |
| 3연쇄+ | **+45%** | 1장 드로우 + 기세 +10 |

- **공격 카드 전용** — 스킬/파워는 연쇄 카운트 불가, 사이에 끼면 연쇄 끊김
- 방어(블록)에는 보너스 미적용 (데미지에만 적용)
- 3연쇄 이상은 동일 보너스 (표시도 "3연쇄"로 캡)
- 2연쇄부터 드로우 보상 즉시 발생 → 연쇄 플레이 동기 부여
- 3연쇄가 High 기세(AP 4)에서 노릴 수 있는 현실적 최대치
- 기세 변동: 타입 전환 시 +12, 환경 카드 +20

**기세와의 트레이드오프:**

| 플레이 방식 | 이번 턴 | 다음 턴 |
|------------|---------|---------|
| **전환 플레이** | 기세 유지 (+15/전환) | AP 확보 → 안정적 |
| **연쇄 플레이** | 폭발 데미지 | 기세 하락 → AP 감소 위험 |

3연쇄의 기세 +10은 감소분을 일부 상쇄하지만 완전 상쇄는 아님.

| 연쇄 | 시각 연출 | 메인 텍스트 | 배지 |
|------|----------|-----------|------|
| 2연쇄 | 오렌지 테두리 박스 | "N 데미지! (연쇄 +X)" | "2연쇄! 드로우 +1" |
| 3연쇄 | 오렌지 테두리 박스 (강조) | "N 데미지! (연쇄 +X)" | "3연쇄! 드로우 +1 / 기세 +10" |

---

## 턴 흐름

```
1. 턴 시작: 블록 초기화, 상태 효과 틱, 카드 5장 드로우
2. 적 의도 표시 (일반: 공개 / 엘리트: 2턴간 ???)
3. 플레이어: AP 소모하며 카드 플레이 (순서 자유)
4. 턴 종료: 남은 손패 버림, 적 행동 실행
5. HP 체크 → 계속 or 종료
```

---

## 공통 시작 카드 (7장)

| 카드 | ID | AP | 타입 | 효과 | 업그레이드 |
|------|----|----|------|------|-----------|
| 타격 | strike_1/2/3 | 1 | Attack | 6 데미지 | 8 데미지 |
| 방어 | defend_1/2 | 1 | Skill | 블록 5 | 블록 7 |
| 경계 | starter_vigilance | 1 | Skill | 3 데미지 + 블록 3 | 4 데미지 + 블록 5 |
| 기합 | starter_brace | 0 | Skill | 1장 드로우 + 기세 +5. Exhaust | 2장 드로우 + 기세 +8. Exhaust |

---

## 무색 카드 (30종)

| # | 카드 | ID | AP | 타입 | 키워드 | 효과 | 업그레이드 |
|---|------|----|----|------|--------|------|-----------|
| 1 | 새출발 | freshStart | 1 | Skill | Exhaust | 손패 버리고 5장 드로우 | 7장 드로우 |
| 2 | 위협 | threaten | 0 | Skill | Exhaust | 약화 1턴 | 약화 2턴 |
| 3 | 선제공격 | preemptiveStrike | 0 | Attack | Innate | 3 데미지 | 5 데미지 |
| 4 | 도주 준비 | fleePrepare | 1 | Skill | Retain | 블록 4 + 다음 도망 성공률 100% | 블록 6 + 1장 드로우 |
| 5 | 관찰 | observe | 1 | Skill | — | 블록 5 + 적 의도 공개 + 1장 드로우 | 블록 8 + 2장 |
| 6 | 약점 간파 | exposeWeakness | 1 | Skill | — | 취약 2턴 | 취약 3턴 |
| 7 | 집중 타격 | focusedStrike | 2 | Attack | Exhaust | 20 데미지 | 28 데미지 |
| 8 | 전력 질주 | sprint | 0 | Skill | — | AP +2, 턴 종료 시 손패 전부 소진 | AP +3 |
| 9 | 통찰 | insight | 0 | Skill | — | 2장 드로우 | 3장 드로우 |
| 10 | 연막 | smokeScreen | 1 | Skill | Exhaust | 블록 10 + 약화 1턴 | 블록 15 |
| 11 | 치명타 | criticalStrike | 1 | Attack | — | 12 데미지 (기세 High: 24) | 18 (High: 36) |
| 12 | 기세 충전 | momentumCharge | 1 | Skill | Exhaust | 기세 +20 | +30 |
| 13 | 환경 폭발 | environmentExplosion | 2 | Attack | Exhaust | 25 고정 데미지 (관통) | 35 데미지 |
| 14 | 독 항아리 | poisonJar | 1 | Skill | Exhaust | 독 5 | 독 8 |
| 15 | 흡수 | absorb | 1 | Skill | — | HP 6 회복 | HP 10 |
| 16 | 위협 사격 | threateningShot | 1 | Attack | — | 6 데미지 + 약화 1턴 | 9 데미지 |
| 17 | 이중타격 | doubleStrike | 1 | Attack | — | 4 데미지 × 2회 | 6 × 2 |
| 18 | 인내 | patience | 0 | Skill | Retain | 블록 3 | 블록 5 |
| 19 | 속임수 | trickery | 0 | Skill | — | 손패 1장 소진 → 2장 드로우 | 3장 드로우 |
| 20 | 최후의 발악 | lastStand | 1 | Attack | Exhaust | 현재 HP 10% 데미지 | 15% |
| 21 | 저력 | endurance | 1 | Power | — | 매 턴 HP 2 회복 | HP 3 |
| 22 | 결전 | finalBattle | 2 | Attack | Exhaust | 8 데미지 × 3회 | 10 × 3 |
| 23 | 임기응변 | improvise | 0 | Skill | — | 블록 4 + 1장 드로우 | 블록 6 + 2장 |
| 24 | 약자의 분노 | wrathOfWeak | 1 | Attack | — | HP ≤50%: 20뎀, 아니면 8 | 25 / 10 |
| 25 | 절약 | thrift | 0 | Skill | — | 남은 AP × 5 블록 | × 7 |
| 26 | 수집가 | collector | 1 | Skill | Exhaust | 2장 드로우 | 3장 |
| 27 | 과감한 도박 | boldGamble | 1 | Attack | Exhaust | 5~30 랜덤 데미지 | 8~35 |
| 28 | 시간 되감기 | timeRewind | 2 | Skill | Exhaust | 소진 파일에서 1장 복귀 | 2장 |
| 29 | 소용돌이 | whirlwind | 2 | Attack | — | 전체 적 6 데미지 × 3회 | 8 × 3 |
| 30 | 명상 | meditation | 1 | Skill | — | 블록 8 + 기세 +15 + 1장 드로우 | 블록 12 + 기세 +20 + 2장 |

> 29~30번(소용돌이/명상)은 소울 업그레이드로 해금 후 카드 보상에 등장.

---

## 환경 카드 (11종)

**해금:** 관찰 사용 시 → 업그레이드 버전 손패 추가. 관찰 없이 3턴 경과 → 기본 버전 추가.
전투당 1종 (전투 시작 시 결정), Exhaust.

### 일반 환경 카드 (6종)

| 카드 | ID | AP | 효과 | 업그레이드 | 출현 |
|------|----|----|------|-----------|------|
| 천장 낙석 | ceilingCollapse | 1 | 20 고정 데미지 | 30 데미지 | 동굴/하수도 |
| 늪의 독기 | swampMiasma | 1 | 독 8 | 독 12 | 늪/하수도 |
| 사슬 속박 | chainBind | 1 | 약화 2 + 취약 2 | 3 + 3 | 감옥 |
| 마력 결정 | manaCrystal | 1 | AP +2 이번 턴 | 0AP 비용 | 마나 광산 |
| 제단의 불꽃 | altarFlame | 2 | 25 데미지 + 화상 5 | 1AP + 30뎀 + 화상 8 | 사원 |
| 심연의 균열 | abyssalRift | 2 | 적 최대 HP 15% 데미지 | 20% | 심층 |

### 보스전 환경 카드 (5종)

| 보스 | 카드 | ID | AP | 효과 | 업그레이드 |
|------|------|----|----|------|-----------|
| 슬라임 왕 | 염산 웅덩이 | acidPool | 1 | 재생 무효 3턴 | 0AP + 5턴 |
| 거미 군주 | 거미줄 역이용 | webReversal | 1 | 스턴 1턴 | 0AP + 2턴 |
| 오크 대장군 | 함정 기동 | trapTrigger | 1 | 적 버프 초기화 | 0AP + 약화 2 |
| 뱀파이어 군주 | 성수 | holyWater | 1 | 10뎀 + 흡혈 무효 3턴 | 0AP + 15뎀 + 5턴 |
| 던전 마스터 | 근원의 빛 | primordialLight | 1 | 취약 3 (현재 페이즈) | 0AP + 5턴 |

---

## 덱빌딩

| 시점 | 이벤트 | 선택 |
|------|--------|------|
| 전투 승리 | 카드 보상 | 3장 중 1장 추가 or 스킵 |
| 유령 전투 승리 | 유령 직업 카드 보상 | 유령 직업 카드 2장 + 무색 1장 중 선택 |
| 상점 | 카드 구매/제거 | 구매(가변), 제거(35G) |
| 이벤트 | 특수 카드 | 이벤트별 고유 보상 |
| 휴식 | 회복 or 강화 | HP 30% 회복 OR 최대HP +10 |
| NPC | 아이템 구매 | NPC 축복/보급품 |
| 축복 보상 | 규칙 변경 | 2개 중 1개 선택 |
| 엘리트 보상 | 유물 | 유물 + 카드 보상 |

**덱 초기화 흐름:**
1. 런 시작 → 공통 시작 카드 7장 (타격×3 + 방어×2 + 경계×1 + 기합×1)
2. 분화 전에도 상점/보상으로 카드 획득 가능 (masterDeck에 누적)
3. 직업 분화 시 → starter_ 카드를 직업 시작 덱(12장)으로 교체 + 획득 카드 보존

**덱 크기 전략:**
- 작은 덱 (12~14장): 핵심 카드 자주 드로우 → 콤보 일관성
- 큰 덱 (15~20장): 다양한 상황 대응 → 유연성
- 카드 제거 = 강해지는 방법

**하이브리드 덱 (유령 전투):**
- 유령 NPC 전투 승리 시 유령의 직업 카드 풀에서 보상 (`rewardJobOverride`)
- 다른 직업 카드를 내 덱에 섞어 하이브리드 빌드 가능
- 1차 전직 유령: 직업 카드 2장 + 무색 1장 / 2차 전직 유령: 무색 3장

---

## CardEffectType (135종)

### 코어 + 어드밴스 (69종)
`absorbStrength`, `adaptiveDamage`, `allTypesApBonus`, `apGain`, `apPenaltyNextTurn`, `applyBurn`, `applyPoison`, `applyVulnerable`, `applyWeak`, `blockPerCardPlayed`, `blockPerTurnStart`, `blockPerTurnStartConditional`, `blockRetain`, `block`, `boostLowestStat`, `cleanse`, `coinFlip`, `conditionalBlock`, `conditionalDamage`, `copyLastAttack`, `cycleHand`, `damage`, `damageEqualLostHp`, `damagePerHandCard`, `discardAndDraw`, `doubleNextAttack`, `drainNullify`, `draw`, `equalizeHpBlock`, `executeHpPercent`, `exhaustAndDraw`, `fixedDamage`, `gainDexterity`, `gainRegenerate`, `gainStrength`, `gainThorn`, `generateAttackPerTurn`, `generateRandomCard`, `heal`, `healOnKill`, `highMomentumBonus`, `hpPercentDamage`, `ignoreBlock`, `immuneThisTurn`, `mimicEnemyDamage`, `momentumGain`, `multiHit`, `nothing`, `playRestriction`, `poisonMultiplierDamage`, `randomDamage`, `randomDebuffs`, `regenNullify`, `replayLastCard`, `resetEnemyBuff`, `retribution`, `retrieveFromDiscard`, `retrieveRandomPerTurn`, `revealIntent`, `selfDamage`, `selfDamagePerTurn`, `setFleeGuaranteed`, `setPoisonPerTurn`, `splitHpToBlock`, `sprintExhaust`, `strengthPerTurn`, `stunEnemy`, `thornMultiplierDamage`, `transformHandPerTurn`

### 콘텐츠 확장 (16종)
`lifesteal`, `poisonBurst`, `dodgeChance`, `healPerAttackPlayed`, `lostHpToBlockPerTurn`, `conditionalDamageEnemyHp`, `damagePerExhaust`, `handSizeBlock`, `skillCountDamage`, `remainingApBlock`, `retrieveFromExhaust`, `reflectDamageChance`, `swapStrDex`, `statSumDamage`, `healPerTurn`, `drawPerTurn`

### 전투 오버홀 (13종)
`lifestealOnAllAttacks`(전체 Attack 흡혈), `healPerTurnConditional`(조건부 턴 회복), `excessDamageLifesteal`(초과 데미지 흡혈), `nextSkillApDiscount`(다음 Skill AP-1), `overflowToBlock`(관통 초과→블록), `cooldownAfterUse`(N턴 쿨다운), `momentumGainOnDodge`(회피 시 기세), `poisonDamageReduction`(독 스택당 피해 감소), `immuneNextHits`(N회 피격 무효), `damageReductionWhenBlock`(블록 조건 피해 감소), `healOnDamageTaken`(피격 시 회복), `healOnReflect`(반사 시 회복), `nextHitDamageReduction`(다음 피격 데미지 감소)

### 2차 전직 (37종)
`poisonEffectivenessBoost`(독 증폭), `blockRetainFull`(블록 100% 유지), `reflectDamagePercent`(데미지 반사%), `blockToDamageKeepBlock`(블록→데미지+유지), `blockPerTurnFixed`(매턴 고정 블록), `damageReductionAtBlock`(블록 조건 피해 감소), `randomBuff`(랜덤 버프), `retrieveFromExhaustPile`(소진→복원), `exhaustPileCountDamage`(소진수×데미지), `generateRandomCardAndHealPerTurn`(랜덤 카드+회복), `executeHpPercentInstantKill`(HP% 즉사), `lifestealWithSelfDamage`(자해+흡혈), `lostHpMultiplierDamage`(잃은HP 배율 데미지), `emergencyBlockAndHeal`(긴급 블록+치유), `copyLastAttackToHand`(Attack 복제), `copyLastCardMultiple`(카드 다중 복제), `allAttackPiercing`(전체 Attack 관통), `handCountBlock`(손패수 블록), `drawPerTurnAndSkillDiscount`(드로우+Skill 할인), `allSkillApDiscount`(전체 Skill AP-), `lifestealOnAllAttacksPercent`(전체 Attack %흡혈), `healPercentOfDamageDealt`(딜 비례 회복), `nextAttackDamageBoost`(다음 Attack 강화), `poisonPerTurnAndDraw`(독+드로우), `blockToDamagePartialRetain`(블록→데미지+부분 유지), `blockRetainPercentAndStrength`(블록 유지+힘), `convertPoisonToDamageAndHeal`(독→데미지+치유), `damageOnCleanse`(정화 시 데미지), `multiHitPiercing`(다회 관통), `allStatsDamage`(전스탯 데미지), `boostLowestStatPerTurn`(최저 스탯 강화), `cardsPlayedDamage`(사용 카드수 데미지), `equalizeHpAndBlock`(HP-블록 균등화), `revealIntentAndDraw`(의도 공개+드로우), `poisonPerTurnAndDodge`(독+회피), `poisonStackMultiplierDamage`(독 배율 데미지), `multiHitWithPoison`(다회+독)

---

## 카드 타겟 유형 (CardTargetType)

| 타입 | 설명 | 동작 |
|------|------|------|
| **single** (기본) | 단일 대상 | 선택된 적 1체에게 효과 적용 |
| **all** | 전체 대상 (AoE) | 살아있는 모든 적에게 효과 적용 |

카드의 `targetType` 필드가 null이면 single로 동작. 멀티몹 전투에서 AoE 카드는 모든 적에게 데미지/상태효과를 각각 적용.

### AoE 카드 목록

| 카드 | 직업 | 효과 |
|------|------|------|
| 회전참 | 전사 | 6 데미지 전체 |
| 연쇄 번개 | 마법사 | 9 데미지 전체 |
| 칼날 비 | 암살자 | 4×3 데미지 전체 |
| 독안개 | 약사 | 독 4 전체 |
| 독 폭발 | 약사 | 독 스택 비례 데미지 전체 |
| 환각 폭풍 | 광대 | 랜덤 디버프 전체 |
| 대혼란 | 광대 | 약화+취약 전체 |
| 천장 낙석 | 환경 | 20 고정 데미지 전체 |
| 늪의 독기 | 환경 | 독 8 전체 |
| 제단의 불꽃 | 환경 | 25 데미지 + 화상 5 전체 |
| 심연의 균열 | 환경 | 최대 HP 15% 데미지 전체 |

---

## 2차 전직 카드

상위직 9종 × 5장 = 45장, 조합직 5종 × 5장 = 25장. 총 70장 (업그레이드 포함 140 버전).
각 직업별 카드 상세는 `JOBS.md` Phase 4 섹션 참조. CardEffectType은 위 "2차 전직 (37종)" 참조.

---

## 소스 파일 참조

| 데이터 | 파일 |
|--------|------|
| 공통 시작 카드 | `lib/domain/combat/content/starter_cards.dart` |
| 무색 카드 30종 | `lib/domain/combat/content/colorless_cards.dart` |
| 환경 카드 11종 | `lib/domain/combat/content/environment_cards.dart` |
| 상위직 카드 (9파일) | `lib/domain/combat/content/{upper_job}_cards.dart` |
| 조합직 카드 (5파일) | `lib/domain/combat/content/{combo_job}_cards.dart` |
| 연쇄 보너스 | `lib/domain/combat/logic/chain_bonus.dart` |
| CardData 모델 | `lib/core/models/card_data.dart` |
| CardEffectType enum | `lib/core/models/game_enums.dart` |
| CardTargetType enum | `lib/core/models/game_enums.dart` |
| 직업별 카드 (9파일) | `lib/domain/combat/content/{job}_cards.dart` |
| 카드 보상 생성 | `lib/domain/combat/logic/card_reward_generator.dart` |
| 카드 풀 (직업별 보상) | `lib/domain/combat/content/card_pool.dart` |
| 밸런스 설정 | `assets/config/balance.json` |
