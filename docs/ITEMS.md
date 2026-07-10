# 아이템 레퍼런스

전투 축복 33종 + 기본 축복 8종 + NPC 축복 6종 + 전투 유물 20종 + 카드 유물 12종 + 기본 유물 14종 + 저주 10종 + 악마의 거래 14종 + 상점 보급품 8종 + NPC 보급품 10종.

---

## 총괄 요약

| 카테고리 | 수량 | 획득처 |
|----------|------|--------|
| 전투 축복 (CardBlessing) | 33 (7C + 17R + 9L) | 전투 보상, 상점, 이벤트 |
| 기본 축복 (Blessing) | 8 | 상점, 이벤트, 보상 |
| NPC 축복 | 6 | NPC 상인 전용 |
| 악마의 축복 | 4 | 악마의 거래 전용 |
| 전투 유물 (CardRelic) | 20 (3C + 10R + 7L) | 엘리트 보상, 상점 |
| 카드 유물 (CardRelic) | 12 | 보상, 이벤트 |
| 기본 유물 (Relic) | 14 (4C + 6R + 4L) | 이벤트, 보상 |
| 악마의 축복 및 저주 | 4+10 | 악마의 거래 |
| 저주 변형 (E9) | 4종 × 0~5레벨 | 클리어 후 난이도 |
| 상점 보급품 | 8 | 상점 판매 |
| NPC 보급품 | 10 | NPC 상인 전용 |

---

## 전투 축복 (33종)

전투 중 적용되는 규칙 변경. 빌드 핵심.

### Common (7종)

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 1 | cb_thorn | 가시 | 피격 시 공격자에게 5 데미지 | onHit |
| 2 | cb_rage | 분노 | 블록 안 된 피격 시 무료 타격 손패 추가 | onHit |
| 4 | cb_leech | 흡혈 | 공격 데미지 12% HP 회복 | onAttack |
| 5 | cb_patience | 인내 | 블록 다음 턴 50% 유지 | turnStart |
| 6 | cb_sharp | 날카로움 | 힘 +1 (영구) | combatStart |
| 7 | cb_tough | 단단함 | 민첩 +1 (영구) | combatStart |
| 8 | cb_quick_feet | 빠른 발 | 매 턴 +1 드로우 | turnStart |

### Rare (17종)

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 3 | cb_swift | 신속 | 매 턴 첫 카드 AP -1 | onCardPlay |
| 9 | cb_poison_master | 독의 대가 | 독 데미지 2배 | passive |
| 10 | cb_afterimage | 잔상 | Attack 25% 확률 복사본 생성 | onAttack |
| 11 | cb_reflex | 반사 신경 | 매 턴 블록 3 자동 획득 | turnStart |
| 12 | cb_tenacity | 집념 | 버린 카드 1장 다음 턴 복귀 | turnStart |
| 13 | cb_chain | 연쇄 | 0AP 카드 사용 시 1장 드로우 | onCardPlay |
| 14 | cb_overload | 과부하 | AP +1, 매 턴 HP -5 | turnStart |
| 15 | cb_momentum_burst | 기세 폭발 | 기세 High 진입 시 적 15 데미지 | passive |
| 16 | cb_optimize | 최적화 | 첫 턴 Innate 2장 추가 드로우 | combatStart |
| 23 | cb_flame_blood | 화염 핏줄 | 모든 Attack에 화상 2 추가 | onAttack |
| 24 | cb_glass_cannon | 유리대포 | 힘 +5, 최대 HP -20 | combatStart |
| 25 | cb_sands_of_time | 시간의 모래 | 5턴마다 AP +2 | turnStart |
| 26 | cb_vampire | 흡혈귀 | 모든 공격·독·화상 데미지의 15% HP 회복 | onAttack |
| 27 | cb_iron_skin | 강철 피부 | 매 턴 시작 시 블록 5 | turnStart |
| 28 | cb_momentum_master | 기세의 달인 | 기세 변동량 +30% | passive |
| 29 | cb_card_master | 카드의 달인 | 카드 사용 시 10% 확률 AP 환불 | onCardPlay |
| 30 | cb_executioner | 처형인 | 적 HP 20% 이하 시 데미지 2배 | onAttack |

### Legendary (9종)

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 17 | cb_blood_contract | 피의 계약 | 카드 업그레이드 HP -10 (무료) | passive |
| 18 | cb_infinite_cycle | 무한 순환 | 덱 셔플 시 힘 +1, 민첩 +1 | onShuffle |
| 19 | cb_perfect_form | 완벽한 형태 | 매 턴 AP +1, 피격 시 2턴 소멸 | turnStart |
| 20 | cb_devour | 독식 | 적 처치 시 최대 HP +1 (영구) | onKill |
| 21 | cb_reaper | 사신의 낫 | 적 HP <5% 즉사 | onAttack |
| 22 | cb_echo | 에코 | 매 턴 마지막 Attack 카드 다음 턴 복사 | turnEnd |
| 31 | cb_immortal | 불멸 | 치명타 시 HP 1로 생존 (1회) | onHit |
| 32 | cb_double_edge | 양날의 검 | 모든 데미지 +50%, 받는 데미지 +25% | passive |
| 33 | cb_soul_harvest | 영혼 수확 | 적 처치 시 랜덤 카드 1장 생성 | onKill |

### 축복 트리거 (9종)

`combatStart`, `turnStart`, `turnEnd`, `onAttack`, `onHit`, `onCardPlay`, `onKill`, `onShuffle`, `passive`

---

## 기본 축복 (8종)

### Common (4종)

| ID | 이름 | 효과 | effectType |
|----|------|------|-----------|
| blessing_001 | 힘의 축복 | 전투 시작 시 힘 +1 | attackBonus |
| blessing_002 | 방어의 축복 | 전투 시작 시 블록 +3 | defenseBonus |
| blessing_003 | 속도의 축복 | 전투 시작 시 드로우 +1 | bonusDraw |
| blessing_004 | 생명의 축복 | 전투 시작 시 HP 5 회복 | healOnCombatStart |

### Rare (4종)

| ID | 이름 | 효과 | effectType |
|----|------|------|-----------|
| blessing_005 | 기세의 축복 | 전투 시작 시 기세 +10 | momentumOnCombatStart |
| blessing_006 | 회피의 축복 | 첫 피격 시 데미지 50% 감소 | firstHitReduction |
| blessing_007 | 집중의 축복 | 전투 시작 시 AP +1 (첫 턴만) | bonusApFirstTurn |
| blessing_008 | 재생의 축복 | 매 턴 시작 시 HP 2 회복 | healPerTurn |

---

## NPC 축복 (6종 — 상인 전용)

| ID | 이름 | 효과 |
|----|------|------|
| npc_blessing_001 | 은둔자의 부적 | 전투 시작 시 방어 +2 |
| npc_blessing_002 | 여행자의 부적 | 전투 시작 시 기세 +5 |
| npc_blessing_003 | 전사의 완장 | 전투 시작 시 힘 +1 |
| npc_blessing_004 | 치유의 부적 | 전투 시작 시 HP 3 회복 |
| npc_blessing_005 | 행운의 동전 | 전투 시작 시 카드 1장 추가 드로우 |
| npc_blessing_006 | 인내의 반지 | 블록 25% 다음 턴 유지 |

---

## 전투 유물 (20종)

### Common (3종)

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 5 | cr_wind_amulet | 바람의 부적 | 도망 성공률 +30% | onFlee |
| 13 | cr_lucky_coin | 행운의 금화 | 전투 승리 시 골드 +8 | onKill |
| 14 | cr_thorn_bracelet | 가시 팔찌 | 가시 1 (영구) | combatStart |

### Rare (10종)

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 1 | cr_blood_ring | 핏빛 반지 | 전투 시작 시 힘 +2 | combatStart |
| 2 | cr_magic_stone | 마력석 | 매 턴 +1 드로우 | turnStart |
| 3 | cr_thorn_shield | 가시 방패 | 블록 10+ 시 가시 2 | onBlock |
| 4 | cr_poison_vial | 독약병 | 전투 시작 시 독 항아리 손패 추가 | combatStart |
| 6 | cr_soul_stone | 영혼석 | 적 처치 시 HP 5 회복 | onKill |
| 9 | cr_flame_ring | 화염의 반지 | 모든 Attack에 화상 1 추가 | onAttack |
| 10 | cr_ice_crystal | 얼음 수정 | 매 턴 적 1체 약화 1턴 | turnStart |
| 11 | cr_healing_pendant | 치유의 펜던트 | 매 턴 HP 2 회복 | turnStart |
| 12 | cr_card_bag | 카드 주머니 | 전투 시작 시 랜덤 무색 카드 1장 추가 | combatStart |
| 15 | cr_momentum_gem | 기세의 보석 | 전투 시작 시 기세 +10 | combatStart |

### Legendary (7종)

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 7 | cr_destruction_hammer | 파괴의 망치 | 기세 High 진입 시 다음 Attack +8 | onMomentumHigh |
| 8 | cr_mirror_shard | 거울 조각 | 턴 시작 시 20% 확률 손패 1장 복사 | turnStart |
| 16 | cr_time_hourglass | 시간의 모래시계 | 5턴마다 AP +1 | turnStart |
| 17 | cr_phoenix_feather | 불사조 날개 | HP 0 시 1회 부활 (HP 10% 회복) | onHit |
| 18 | cr_void_shard | 공허의 조각 | 소진 카드 5장마다 모든 적 10 데미지 | passive |
| 19 | cr_ancient_crown | 고대의 왕관 | 전투 시작 시 힘+2, 민첩+2 | combatStart |
| 20 | cr_cursed_blade | 저주받은 검 | 힘+4, 매 턴 HP -2 | combatStart |

---

## 카드 유물 (12종)

카드에 부착되는 유물. 특정 카드 트리거에 반응.

| # | ID | 이름 | 효과 | 트리거 |
|---|-----|------|------|--------|
| 1 | card_relic_001 | 카드의 영혼 | 업그레이드 카드 비용 -1 | onUpgrade |
| 2 | card_relic_002 | 혼합의 보석 | 같은 종류 카드 3장 연속 사용 시 비용 -2 | onCombo |
| 3 | card_relic_003 | 에너지 수정 | 0AP 카드 사용 시 다음 카드 비용 -1 | onCardPlay |
| 4 | card_relic_004 | 명상의 부적 | 매 턴 마지막 카드 비용 -1 | turnEnd |
| 5 | card_relic_005 | 강화의 결정 | 업그레이드된 카드 효과 +20% | onUpgrade |
| 6 | card_relic_006 | 연쇄의 보석 | 콤보 발동 시 기세 +10 | onCombo |
| 7 | card_relic_007 | 번개 결정 | Attack 연속 3장 비용 -1 | onAttack |
| 8 | card_relic_008 | 어둠의 영혼 | 디버프 카드 사용 시 적 기세 -5 | onHit |
| 9 | card_relic_009 | 재생의 보석 | 방어 카드 사용 시 HP 3 회복 | onBlock |
| 10 | card_relic_010 | 마력의 오브 | 기술 카드 사용 시 AP +1 | onCardPlay |
| 11 | card_relic_011 | 영원의 반지 | 턴 시작 시 손패 1장 비용 -1 (최대 3장) | turnStart |
| 12 | card_relic_012 | 파괴의 핵심 | 3 이상의 공격력 카드 비용 -1 | onAttack |

---

## 기본 유물 (14종)

### Common (4종)

| ID | 이름 | 효과 | 트리거 |
|----|------|------|--------|
| relic_001 | 녹슨 부적 | 전투 시작 시 기세 5 | combatStart |
| relic_002 | 치유의 돌 | 방 이동 시 HP 2 회복 | roomEnter |
| relic_003 | 행운의 동전 | 전투 승리 시 골드 +5 | combatEnd |
| relic_004 | 강화 가죽 | 전투 시작 시 방어 +3 | combatStart |

### Rare (6종)

| ID | 이름 | 효과 | 트리거 |
|----|------|------|--------|
| relic_005 | 바람의 깃털 | 기세 60+ 시 공격 +8 | momentumThreshold |
| relic_006 | 치유의 샘물 | 층 이동 시 HP 10 | floorTransition |
| relic_007 | 탐험가의 나침반 | 방 이동 시 기세 +3 | roomEnter |
| relic_008 | 고대 주화 주머니 | 전투 승리 시 골드 +10 | combatEnd |
| relic_011 | 모험가의 지도 | 미스터리 방 결과 2개 중 선택 | mysteryRoom |
| relic_012 | 장인의 망치 | 상점 카드 업그레이드 비용 -50% | shop |

### Legendary (4종)

| ID | 이름 | 효과 | 트리거 |
|----|------|------|--------|
| relic_009 | 불사조의 깃털 | HP 20% 이하 시 피해 -15 | hpThreshold |
| relic_010 | 고대의 반지 | 전투 시작 시 기세 +15 | combatStart |
| relic_013 | 차원의 주머니 | 상점 카드 제거 비용 무료 (1회/층) | shop |
| relic_014 | 영원의 심장 | 매 층 시작 시 최대HP +3 | floorTransition |

---

## 상점 보급품 (8종 — 상점 판매)

| ID | 이름 | 효과 | effectType |
|----|------|------|-----------|
| supply_001 | 치유의 물약 | HP 20 회복 | heal |
| supply_002 | 기세의 대부적 | 다음 전투 시작 기세 +30 | momentumBonus |
| supply_005 | 응급 붕대 | HP 10 회복 | heal |
| supply_007 | 카드 교환권 | 덱 카드 1장 → 랜덤 무색 카드 교체 | cardExchange |
| supply_008 | 정화의 물 | 저주 1개 제거 | removeCurse |
| supply_009 | 강화 망치 | 랜덤 카드 1장 업그레이드 | upgradeRandomCard |
| supply_010 | 기세의 부적 | 다음 전투 시작 기세 +15 | momentumBonus |
| supply_011 | 생명의 과일 | 최대 HP +5 (영구) | maxHpBonus |

---

## NPC 보급품 (10종 — 상인 전용)

| ID | 이름 | 효과 |
|----|------|------|
| npc_supply_001 | 방랑자의 물약 | HP 10 회복 |
| npc_supply_003 | 여행자의 붕대 | HP 5 회복 |
| npc_supply_004 | 기력 회복제 | HP 5 회복 |
| npc_supply_005 | 힘의 물약 | 다음 전투 힘 +3 |
| npc_supply_006 | 보호의 두루마리 | 다음 전투 블록 10 |
| npc_supply_007 | 카드 교환권 | 덱 카드 1장 → 랜덤 무색 카드 교체 |
| npc_supply_008 | 정화의 물 | 저주 1개 제거 |
| npc_supply_009 | 강화 망치 | 랜덤 카드 1장 업그레이드 |
| npc_supply_010 | 기세의 부적 | 다음 전투 시작 기세 +15 |
| npc_supply_011 | 생명의 과일 | 최대 HP +5 (영구) |

---

## 악마의 거래

저주와 축복을 교환. 고위험 고보상.

### 악마의 축복 (4종 — Cursed 희귀도)

| ID | 이름 | 효과 |
|----|------|------|
| devil_blessing_001 | 피의 계약 | 전투 시작 시 힘 +3 |
| devil_blessing_002 | 그림자 갑옷 | 전투 시작 시 방어 +5 |
| devil_blessing_003 | 심연의 눈 | 전투 시작 시 기세 +10 |
| devil_blessing_004 | 광기의 힘 | 전투 시작 시 힘 +2, 방어 +3 |

### 악마의 저주 (10종)

| ID | 이름 | 효과 |
|----|------|------|
| curse_001 | 약화 | 최대 HP 10% 감소 |
| curse_002 | 둔감 | 기세 획득 20% 감소 |
| curse_003 | 불운 | 상점 가격 15% 증가 |
| curse_004 | 적의 | 적 공격력 10% 증가 |
| curse_005 | 혼란 | 서술자 신뢰도 감소 |
| curse_006 | 소모 | 기세 감쇠 50% 가속 |
| curse_007 | 무거운 발 | 매 전투 드로우 -1 |
| curse_008 | 저주받은 손 | 첫 턴 AP -1 |
| curse_009 | 그림자 추적 | 매 전투 시작 시 HP -3 |
| curse_010 | 망각 | 카드 업그레이드 비용 +30% |

### 거래 조합 (14종)

| ID | 축복 | 저주 | 대사 |
|----|------|------|------|
| deal_001 | 피의 계약 | 약화 | 힘을 원하는가? 대가는 육체의 쇠약. |
| deal_002 | 그림자 갑옷 | 둔감 | 단단해지고 싶은가? 대신 둔해질 것이다. |
| deal_003 | 심연의 눈 | 혼란 | 진실을 보고 싶은가? 그 눈은 혼란을 부른다. |
| deal_004 | 광기의 힘 | 적의 | 절대적 힘... 하지만 적도 강해진다. |
| deal_005 | 피의 계약 | 소모 | 공격의 극한. 대가는 기세의 소모. |
| deal_006 | 그림자 갑옷 | 둔감 | 방어는 얻으나, 감각은 둔해진다. |
| deal_007 | 심연의 눈 | 불운 | 눈은 열리지만, 금화가 새어나간다. |
| deal_008 | 광기의 힘 | 약화 | 전장의 왕이 되리라. 육체가 버틸 수 있다면. |
| deal_009 | 피의 계약 | 불운 | 저렴한 거래라고? 세상에 공짜는 없다네. |
| deal_010 | 심연의 눈 | 적의 | 진실을 보는 눈... 적도 당신을 더 잘 보게 되지. |
| deal_011 | 피의 계약 | 무거운 발 | 힘을 원하느냐? 대가는 둔한 손놀림. |
| deal_012 | 그림자 갑옷 | 저주받은 손 | 방어를 얻되, 첫 순간의 주저함을 받아들여라. |
| deal_013 | 심연의 눈 | 그림자 추적 | 통찰의 눈... 하지만 어둠이 네 생명을 갉아먹는다. |
| deal_014 | 광기의 힘 | 망각 | 강해지리라. 다만 과거의 기술은 잊혀지리니. |

---

## 저주 변형 (E9 난이도 — 4종)

클리어 후 난이도 레벨 0~5. 독립 적용.

| ID | 이름 | 효과 | 레벨 스케일링 |
|----|------|------|-------------|
| curse_mod_combat | 전투의 저주 | 매 전투 적 힘 증가 | 0/2/3/5/7/10 |
| curse_mod_deck | 덱의 저주 | 카드 보상 감소 + 상점 가격 증가 | 레벨별 배율 |
| curse_mod_card | 카드의 저주 | 시작 덱에 저주 카드 추가 | 0/1/1/2/2/3장 |
| curse_mod_narrator | 서술자의 저주 | 왜곡 시작 층 앞당김 | 0/0/1/1/2/2층 |

---

## 시너지 빌드 예시

| 빌드 | 직업 | 핵심 축복/유물 | 시너지 |
|------|------|---------------|--------|
| 철벽 가시 | 수호자 | 가시 + 인내 + 가시 방패 | 블록 유지+가시 = 방어만 해도 딜 |
| 무한 독 | 암살자 | 독의 대가 + 독안개 + 집념 | 독날 재사용 + 독 2배 |
| 원턴킬 | 현자 | 과부하 + 잔상 + 에코 | AP 4 + 공격 복사 + 반복 |
| 불사 전사 | 전사 | 흡혈 + 광전사 + 영혼석 | 저HP 힘 → 흡혈 복귀 |
| 행운 폭발 | 방랑자 | 잔상 + 에코 + 연쇄 | 0AP 카드 연쇄 + 복사 |

---

## 소스 파일 참조

| 데이터 | 파일 |
|--------|------|
| 전투 축복 33종 | `lib/domain/build/data/card_blessing_pool.dart` |
| 전투 축복 모델 | `lib/core/models/card_blessing_data.dart` |
| 기본 축복 18종 | `lib/domain/build/data/blessing_pool.dart` |
| 축복 JSON | `assets/content/blessings.json` |
| 전투 유물 20종 | `lib/domain/build/data/card_relic_pool.dart` |
| 전투 유물 모델 | `lib/core/models/card_relic_data.dart` |
| 카드 유물 12종 | `lib/domain/build/data/card_relic_pool.dart` (CardRelic subtype) |
| 카드 유물 모델 | `lib/core/models/card_relic_data.dart` (CardRelic subtype) |
| 기본 유물 14종 | `lib/domain/build/data/relic_pool.dart` |
| 유물 JSON | `assets/content/relics.json` |
| 상점 보급품 8종 | `lib/domain/dungeon/shop/shop_item_generator.dart` |
| 악마의 거래 14종 | `lib/domain/build/data/curse_pool.dart` |
| 저주/거래 JSON | `assets/content/curses.json` |
| 악마의 축복/저주 | `lib/core/models/devil_deal_data.dart` |
| 저주 변형 4종 | `lib/core/models/curse_modifier_pool.dart` |
| 저주 변형 모델 | `lib/core/models/curse_modifier_data.dart` |
| NPC 축복/보급품 | `lib/domain/dungeon/npc/npc_generator.dart` |
