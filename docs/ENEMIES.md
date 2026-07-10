# 적 & 보스 레퍼런스

적 40종(일반 25 + 엘리트 15) + 보스 15종 + 유령 전투(6원형). 5층 × 8적(5일반 + 3엘리트). 적 변형 5종. 멀티몹 전투 지원.

---

## 총괄 요약

| 층 | 테마 | 일반 5종 | 엘리트 3종 | 보스 3종 (랜덤 1) |
|----|------|----------|-----------|-------------------|
| 1 | 하수도 | 쥐, 슬라임, 고블린, 독 두꺼비, 박쥐 떼 | 고블린 족장, 하수도 거인, **독 두꺼비 여왕** | 슬라임 왕, **하수도 악어**, **쥐 군주** |
| 2 | 지하 감옥 | 해골, 유령, 거미, 감옥 간수, 사슬 유령 | 거미 여왕, 죄수 왕, **사슬 원혼** | 거미 군주, **간수장**, **원혼 사형수** |
| 3 | 마나 광산 | 골렘, 암흑 마법사, 오크, 수정 구체, 마나 포식자 | 미믹, 고대 수호자, **암흑 대마법사** | 오크 대장군, **수정 골렘**, **마나 폭주체** |
| 4 | 심연 사원 | 악마, 가고일, 사령, 타락 사제, 그림자 마수 | 원혼, 심연의 눈, **가고일 수호신** | 뱀파이어 군주, **대악마**, **타락 대사제** |
| 5 | 심층 던전 | 암흑 기사, 리치, 용족, 영혼 파괴자, 공허의 직조자 | 공허의 보행자, 차원의 균열, **리치 군주** | 던전 마스터, **공허의 군주**, **차원 붕괴자** |

---

## 전투 공식

```
playerDamage = (baseDamage + strength)
  → 약화 시 × 0.75
  → 적 취약 시 × 1.5
  → 적 블록 먼저 차감 → 초과분 HP 감소

enemyDamage = enemyAtk × actionMultiplier
  → 플레이어 블록 먼저 차감 → 초과분 HP 감소
  → 플레이어 취약 시 × 1.5
```

---

## 적 행동 유형 (7종)

| 행동 | 배율 | 효과 |
|------|------|------|
| attack | 1.0× | 기본 공격 |
| heavy | 1.8× | 강공격 (charge 후) |
| charge | 0 | 다음 턴 heavy 확정 |
| defend | 0 | DEF만큼 블록 획득 |
| heal | 0 | 최대 HP 20% 회복 |
| buff | 0 | 힘 +3 (엘리트 +4) |
| observe | 0 | 관찰 (데미지 없음) |

---

## 적 의도 표시

| 유형 | 표시 규칙 |
|------|-----------|
| 일반 | 항상 공개 — "쥐가 공격하려 한다 (8)" |
| 엘리트 | 첫 2턴 "???" → 이후 공개. **관찰 시 즉시 해제** |
| 보스 | 항상 공개 (StS 스타일 전략 포커스) |

---

## 상태 효과 (8종)

| 상태 | 타입 | 효과 | 감쇠 |
|------|------|------|------|
| 독 (poison) | 디버프 | 매 턴 X 데미지 | -1/턴 |
| 화상 (burn) | 디버프 | 매 턴 X 데미지 | -1/턴 |
| 약화 (weak) | 디버프 | 공격 데미지 25% 감소 | 턴 기반 |
| 취약 (vulnerable) | 디버프 | 받는 데미지 50% 증가 | 턴 기반 |
| 힘 (strength) | 버프 | 모든 공격 데미지 +X | 영구 |
| 민첩 (dexterity) | 버프 | 모든 방어 블록 +X | 영구 |
| 가시 (thorn) | 버프 | 피격 시 공격자에게 X 데미지 | 영구 |
| 재생 (regenerate) | 버프 | 매 턴 X HP 회복 | 턴 기반 또는 영구 |

---

## 1층: 하수도

> 아래 패턴은 **기본 패턴**. 일반 몹 25종은 각각 **대체 패턴 2개**를 추가 보유 (전투 시작 시 랜덤 선택). 상세: `floor_enemies.dart`

| 적 | ID | HP | ATK | DEF | 타입 | 패턴 (기본) |
|----|----|----|-----|-----|------|-------------|
| 쥐 | enemy_rat | 25 | 10 | 2 | 일반 | attack, attack, attack, attack |
| 슬라임 | enemy_slime | 35 | 8 | 4 | 일반 | defend, attack, attack, defend |
| 고블린 | enemy_goblin | 30 | 12 | 3 | 일반 | attack, charge, heavy |
| 독 두꺼비 | enemy_poison_toad | 28 | 7 | 3 | 일반 | attack, buff, attack |
| 박쥐 떼 | enemy_bat_swarm | 20 | 10 | 1 | 일반 | attack, attack, attack, defend |
| 고블린 족장 | enemy_goblin_chief | 65 | 14 | 5 | **엘리트** | buff, charge, heavy, attack, heal |
| 하수도 거인 | enemy_sewer_giant | 75 | 12 | 6 | **엘리트** | defend, charge, heavy, attack, heal, attack |
| 독 두꺼비 여왕 | enemy_poison_toad_queen | 70 | 13 | 4 | **엘리트** | buff, attack, attack, buff, attack, heal |

---

## 2층: 지하 감옥

| 적 | ID | HP | ATK | DEF | 타입 | 패턴 |
|----|----|----|-----|-----|------|------|
| 해골 | enemy_skeleton | 35 | 10 | 3 | 일반 | attack, attack, charge, heavy |
| 유령 | enemy_ghost | 25 | 11 | 1 | 일반 | attack, attack, attack, observe |
| 거미 | enemy_spider | 40 | 10 | 4 | 일반 | attack, defend, attack |
| 감옥 간수 | enemy_prison_guard | 38 | 12 | 5 | 일반 | buff, attack, charge, heavy |
| 사슬 유령 | enemy_chain_ghost | 30 | 9 | 2 | 일반 | attack, attack, defend, attack |
| 거미 여왕 | enemy_spider_queen | 80 | 16 | 6 | **엘리트** | buff, attack, attack, defend, heal |
| 죄수 왕 | enemy_prisoner_king | 85 | 17 | 7 | **엘리트** | buff, buff, charge, heavy, attack, heal |
| 사슬 원혼 | enemy_chain_wraith | 85 | 15 | 5 | **엘리트** | attack, defend, charge, heavy, attack, heal |

---

## 3층: 마나 광산

| 적 | ID | HP | ATK | DEF | 타입 | 패턴 |
|----|----|----|-----|-----|------|------|
| 골렘 | enemy_golem | 55 | 10 | 8 | 일반 | defend, attack, charge, heavy |
| 암흑 마법사 | enemy_dark_mage | 30 | 16 | 3 | 일반 | buff, attack, attack |
| 오크 | enemy_orc | 50 | 14 | 5 | 일반 | attack, attack, charge, heavy |
| 수정 구체 | enemy_crystal_orb | 45 | 12 | 6 | 일반 | defend, defend, charge, heavy |
| 마나 포식자 | enemy_mana_eater | 35 | 15 | 3 | 일반 | attack, buff, attack, attack |
| 미믹 | enemy_mimic | 90 | 18 | 7 | **엘리트** | defend, charge, heavy, buff, attack, heal |
| 고대 수호자 | enemy_ancient_guardian | 95 | 16 | 9 | **엘리트** | defend, buff, charge, heavy, heal, attack |
| 암흑 대마법사 | enemy_dark_archmage | 95 | 19 | 6 | **엘리트** | buff, buff, charge, heavy, attack, attack |

---

## 4층: 심연 사원

| 적 | ID | HP | ATK | DEF | 타입 | 패턴 |
|----|----|----|-----|-----|------|------|
| 악마 | enemy_demon | 50 | 18 | 6 | 일반 | attack, buff, charge, heavy |
| 가고일 | enemy_gargoyle | 60 | 14 | 10 | 일반 | defend, attack, defend, charge, heavy |
| 사령 | enemy_necromancer | 40 | 20 | 4 | 일반 | buff, attack, attack, attack |
| 타락 사제 | enemy_corrupt_priest | 45 | 16 | 5 | 일반 | buff, attack, heal, attack |
| 그림자 마수 | enemy_shadow_beast | 55 | 20 | 4 | 일반 | attack, attack, charge, heavy |
| 원혼 | enemy_wraith | 100 | 22 | 8 | **엘리트** | buff, charge, heavy, attack, heal, attack |
| 심연의 눈 | enemy_abyss_eye | 110 | 24 | 9 | **엘리트** | buff, charge, heavy, defend, buff, attack, heal |
| 가고일 수호신 | enemy_gargoyle_guardian | 105 | 20 | 11 | **엘리트** | defend, defend, buff, charge, heavy, attack, heal |

---

## 5층: 심층 던전

| 적 | ID | HP | ATK | DEF | 타입 | 패턴 |
|----|----|----|-----|-----|------|------|
| 암흑 기사 | enemy_dark_knight | 65 | 20 | 10 | 일반 | attack, defend, charge, heavy, attack |
| 리치 | enemy_lich | 50 | 24 | 5 | 일반 | buff, attack, buff, charge, heavy |
| 용족 | enemy_dragonkin | 70 | 22 | 8 | 일반 | charge, heavy, attack, attack, defend |
| 영혼 파괴자 | enemy_soul_destroyer | 60 | 22 | 8 | 일반 | attack, buff, charge, heavy, attack |
| 공허의 직조자 | enemy_void_weaver | 55 | 18 | 12 | 일반 | defend, defend, buff, charge, heavy |
| 공허의 보행자 | enemy_void_walker | 120 | 26 | 10 | **엘리트** | buff, charge, heavy, defend, attack, heal, attack |
| 차원의 균열 | enemy_dimension_rift | 130 | 28 | 11 | **엘리트** | buff, buff, charge, heavy, defend, attack, heal, attack |
| 리치 군주 | enemy_lich_lord | 125 | 27 | 10 | **엘리트** | buff, buff, charge, heavy, defend, attack, heal, attack |

---

## 보스 (15종 — 층당 3종 랜덤 1 선택)

| 층 | 보스 | ID | 기믹 | P1 HP | P1 ATK/DEF | P2 HP | P2 ATK/DEF | P3 |
|----|------|----|------|-------|-----------|-------|-----------|-----|
| 1 | 슬라임 왕 | boss_slime_king | regen | 60 | 12/4 | 40 | 10/3 | - |
| 1 | **하수도 악어** | boss_sewer_croc | **bleed** | 65 | 13/5 | 45 | 16/3 | - |
| 1 | **쥐 군주** | boss_rat_monarch | **corruption** | 55 | 11/3 | 40 | 14/4 | - |
| 2 | 거미 군주 | boss_spider_lord | web | 80 | 14/6 | 50 | 18/4 | - |
| 2 | **간수장** | boss_warden_chief | **shackle** | 85 | 15/7 | 55 | 19/5 | - |
| 2 | **원혼 사형수** | boss_ghost_convict | **voidGimmick** | 75 | 16/5 | 50 | 20/3 | - |
| 3 | 오크 대장군 | boss_orc_general | rage | 100 | 16/8 | 60 | 22/5 | - |
| 3 | **수정 골렘** | boss_crystal_golem | **reflect** | 110 | 14/12 | 70 | 18/8 | - |
| 3 | **마나 폭주체** | boss_mana_overload | **corruption** | 90 | 20/5 | 65 | 26/3 | - |
| 4 | 뱀파이어 군주 | boss_vampire_lord | drain | 110 | 18/6 | 60 | 24/4 | - |
| 4 | **대악마** | boss_arch_demon | **bleed** | 115 | 20/7 | 65 | 26/5 | - |
| 4 | **타락 대사제** | boss_corrupt_high_priest | **shackle** | 105 | 17/8 | 60 | 22/6 | - |
| 5 | 던전 마스터 | boss_dungeon_master | formShift | 110 | 20/10 | 90 | 26/5 | 60, 30/8 |
| 5 | **공허의 군주** | boss_void_sovereign | **voidGimmick** | 120 | 22/10 | 90 | 28/6 | - |
| 5 | **차원 붕괴자** | boss_dimension_collapser | **reflect** | 110 | 24/8 | 110 | 30/5 | - |

### 보스 기믹 (10종)

| 기믹 | 태그 | 효과 | 대응 환경 카드 |
|------|------|------|---------------|
| **regen** | - | 매 턴 최대 HP 5% 회복 | 염산 웅덩이 (재생 무효) |
| **web** | - | 플레이어 드로우 -1 | 거미줄 역이용 (스턴) |
| **rage** | - | 피격 시 힘 +2 | 함정 기동 (버프 초기화) |
| **drain** | - | 공격 데미지의 30% HP 회복 | 성수 (흡혈 무효) |
| **formShift** | - | 페이즈별 패턴/스탯 변경 | 근원의 빛 (취약 부여) |
| **bleed** | [출혈] | 공격 시 플레이어에게 화상 2 | - |
| **shackle** | [속박] | 매 턴 플레이어 AP -1 | - |
| **reflect** | [반사] | 받은 데미지 15% 반사 | - |
| **corruption** | [부패] | 매 턴 플레이어 랜덤 디버프 1 | - |
| **voidGimmick** | [공허] | 매 턴 드로우 -1 + 소진 1장 | - |

### 보스 페이즈 패턴

| 보스 | Phase 1 패턴 | Phase 2 패턴 | Phase 3 패턴 |
|------|-------------|-------------|-------------|
| 슬라임 왕 | attack, defend, attack, charge, heavy | attack, heal, attack, attack | - |
| 하수도 악어 | attack, attack, charge, heavy, defend | attack, attack, heavy, attack | - |
| 쥐 군주 | buff, attack, attack, defend, attack | attack, buff, attack, heavy | - |
| 거미 군주 | defend, attack, attack, buff, charge, heavy | attack, attack, heavy, attack | - |
| 간수장 | defend, buff, attack, charge, heavy | attack, attack, charge, heavy | - |
| 원혼 사형수 | attack, attack, buff, charge, heavy | attack, heavy, attack, attack | - |
| 오크 대장군 | buff, attack, charge, heavy, defend | attack, attack, charge, heavy | - |
| 수정 골렘 | defend, defend, attack, charge, heavy | attack, defend, charge, heavy | - |
| 마나 폭주체 | buff, attack, attack, charge, heavy | attack, attack, heavy, attack | - |
| 뱀파이어 군주 | attack, buff, attack, defend, charge, heavy | attack, attack, heavy, heal | - |
| 대악마 | buff, attack, charge, heavy, attack | attack, attack, heavy, attack | - |
| 타락 대사제 | buff, defend, attack, charge, heavy | attack, buff, charge, heavy | - |
| 던전 마스터 | attack, defend, charge, heavy | buff, attack, buff, charge, heavy | attack, attack, charge, heavy, heal |
| 공허의 군주 | buff, attack, defend, charge, heavy | attack, attack, charge, heavy, attack | - |
| 차원 붕괴자 | defend, attack, charge, heavy, buff | attack, attack, heavy, charge, heavy | - |

### 전투 종료 조건

| 조건 | 결과 |
|------|------|
| 적 HP ≤ 0 | 승리 (카드 보상) |
| 플레이어 HP ≤ 0 | 패배 |
| 엘리트 20턴 초과 | 강제 패배 |
| 보스 30턴 초과 | 강제 패배 |
| 도망 (1AP) | 성공률 50%+α, 보스 불가 |

---

## 적 변형 시스템 (Enemy Modifier)

기존 몹에 접두사 수식어를 붙여 스탯 변형. 새 에셋 없이 체감 다양성 2~3배 증가.

| 수식어 | 접두사 | 효과 |
|--------|--------|------|
| **enhanced** | 강화된 | HP×1.3, ATK×1.2 |
| **venomous** | 맹독 | 공격 시 독 3 부여 |
| **enraged** | 분노한 | ATK×1.2, DEF×0.7 |
| **hardened** | 단단한 | DEF×2.0, HP×1.1 |
| **swift** | 신속한 | 패턴에 attack 1개 추가 |

### 변형 확률

| 조건 | 확률 |
|------|------|
| 2층+ 일반/엘리트 | 20% |
| 4층+ 일반/엘리트 | 40% |
| 보스 | 변형 없음 |

---

## 멀티몹 전투 (Multi-Mob)

일반 전투에서 2~3체 동시 조우 지원. 엘리트/보스는 항상 1체.

### 조우 확률

| 적 수 | 확률 | 조건 |
|--------|------|------|
| 1체 | 60% | 모든 층 |
| 2체 | 30% | 모든 층 |
| 3체 | 10% | 3층+ |

### HP 스케일링

멀티몹 시 각 적의 HP는 기본값의 **70~80%**로 축소 (최소 1).

#### 층별 HP/골드 배율

| 층 | 적 HP 배율 | 골드 배율 | 엘리트 수 |
|----|-----------|----------|----------|
| 1층 | 1.0 | 1.0 | 1~2 |
| 2층 | 1.35 | 1.2 | 1~2 |
| 3층 | 1.65 | 1.3 | 1~2 |
| 4층 | 1.85 | 1.4 | 2~3 |
| 5층 | 2.1 | 1.5 | 2~3 |

보스 포함 모든 적에게 적용됨.

### 패턴 다양화

- **대체 패턴**: 일반 몹 25종 각각 기본 패턴 + **대체 패턴 2개** 보유 (총 75패턴).
- **랜덤 선택**: 전투 시작 시 기본/대체 패턴 중 하나를 랜덤 선택.
- **패턴 오프셋**: 같은 종류 적이 2체 이상일 때 `patternOffset`으로 행동 분산 (두 번째 +1, 세 번째 +2).
- 결과: 같은 종류 적 2체가 나와도 **서로 다른 패턴 + 오프셋**으로 행동이 겹치지 않음.

### HP 기반 AI 조건부 분기 (레거시)

일반 몹 전용 기본 오버라이드. 고급 AI(`resolveActionAdvanced`)가 전 유형 커버하지만, 레거시 호환으로 유지.

| 조건 | 기존 행동 | 오버라이드 | 확률 |
|------|-----------|-----------|------|
| HP ≤ 30% | 공격(attack) | 방어 또는 회복 | 50% |
| HP ≤ 50% | 관찰(observe) | 방어(defend) | 100% |
| charge/heavy | - | **오버라이드 금지** (콤보 보장) | - |

### 타겟팅

- **단일 대상 카드**: 선택된 적 1체에만 적용. 2체 이상 생존 시 타겟 선택 필요. **타겟 선택 UI 구현됨.** 카드에 "전체" 배지로 AoE 구분.
- **AoE 카드**: 살아있는 모든 적에게 효과 적용.
- **적 행동**: 각 적이 독립적으로 행동 (패턴/상태효과/오프셋 개별 관리).
- **승리 조건**: 모든 적 사망 시 승리.

---

## 적 AI 시스템

기존 패턴 순환 위에 **반응형 오버라이드 + 페이즈 전환 + 보스 반응형 기믹** 3개 레이어 추가.

### 반응형 오버라이드

매 턴 패턴에서 행동을 가져온 뒤, 조건 체크 → 확률로 다른 행동으로 교체. `EnemyAI.resolveActionAdvanced()`.

| 조건 | 기존 행동 | 오버라이드 | 확률 | 적용 대상 |
|------|-----------|-----------|------|----------|
| 플레이어 블록 ≥ 15 | attack | **buff** | 30% | 전체 |
| 플레이어 블록 = 0 | defend | **attack** | 40% | 전체 |
| 적 HP ≤ 50% | attack | **defend 또는 heal** | 30% | 일반 + 엘리트 |
| 엘리트 HP ≤ 25% | 아무거나 | **격노 상태** (ATK ×1.5, 2턴) ※수식어 "분노한"과 별개 | 40% | 엘리트 |
| 전투 11턴+ | — | 매 턴 힘 +1 | 100% | 엘리트 + 보스 |
| charge/heavy 콤보 중 | — | **오버라이드 불가** | — | 전체 |

**규칙:**
- charge → heavy는 절대 깨지지 않음 (플레이어 예측 가능 보장)
- 오버라이드는 1턴에 최대 1번
- 같은 오버라이드 2턴 연속 불가 (`lastOverrideAction` 추적)

### 엘리트 페이즈 전환

엘리트 HP 50% 도달 시 Phase 2 패턴으로 전환.

```
HP 100~51%: Phase 1 패턴 (기존)
HP 50% 도달: "분노!" 연출 (1턴 강제 buff)
HP 50~0%:   Phase 2 패턴 (공격적)
```

Phase 2 규칙:
- Phase 1 대비 attack 비율 +1 (defend/heal → attack 교체)
- charge → heavy 빈도 증가
- ※ 엘리트 buff는 Phase 무관하게 항상 힘 +4 (일반 몹은 +3)

### 일반 몹 패턴 전환

HP 50% 도달 시 미사용 대체 패턴으로 전환 (`patternSwitched` 플래그).
이미 대체 패턴 2개가 존재하므로 패턴 전환만으로 행동 다양성 2배.

```
전투 시작: 패턴 A (랜덤 선택)
HP 50% 도달: 패턴 B로 전환 (미사용 패턴 중 랜덤)
```

### 보스 반응형 기믹

기존 기믹 효과에 플레이어 상태 반응형 강화 추가. `EnemyAI.resolveGimmickAdvanced()`.

| 보스 | 기믹 | 반응 조건 | 강화 효과 |
|------|------|----------|----------|
| 슬라임 왕 | regen | 플레이어 독/화상 보유 | 재생량 2배 |
| 거미 군주 | web | 플레이어 0AP 카드 사용 | 추가 드로우 -1 (1턴) |
| 오크 대장군 | rage | 3턴 연속 피격 | 광란 (ATK ×2, 1턴) |
| 뱀파이어 군주 | drain | 플레이어 HP <50% | 흡혈 30% → 50% |
| 던전 마스터 | formShift | 플레이어 최고 스탯 감지 | 해당 디버프 부여 |
| 하수도 악어 | bleed | 플레이어 블록 = 0 | 화상 2 → 4 |
| 쥐 군주 | corruption | 플레이어 디버프 ≥ 3 | 추가 공격 1회 |
| 간수장 | shackle | 카드 1장만 사용 | AP 감소 해제 |
| 원혼 사형수 | voidGimmick | 소진 파일 ≥ 5장 | 소진 카드당 2 데미지 |
| 수정 골렘 | reflect | 플레이어 힘 ≥ 5 | 반사 15% → 25% |
| 마나 폭주체 | corruption | Power 카드 사용 | 디버프 면역 1턴 |
| 대악마 | bleed | 화상 스택 ≥ 5 | 화상 전부 즉시 폭발 |
| 타락 대사제 | shackle | Skill 카드 사용 | 50% 확률 AP 감소 무효 |
| 공허의 군주 | voidGimmick | 소진 파일 비어있음 | HP -5 |
| 차원 붕괴자 | reflect | 연쇄 ≥ 3 | 반사 데미지 2배 |

### 장기전 보너스

11턴부터 (10턴 초과) 엘리트/보스에게 매 턴 힘 +1 누적 (무한 터틀링 방지).

---

## 유령 전투 (Ghost PvP)

유령 NPC와의 전투. 과거 런의 사망 데이터(직업/층)로 적 생성. 엘리트 전투로 취급.

### 전투 원형 (6종)

25종 직업을 6가지 전투 원형으로 분류.

| 원형 | HP | ATK | DEF | 대표 직업 |
|------|-----|-----|-----|----------|
| attacker | 50 | 13 | 4 | 전사, 사신, 검성, 마검사, 성기사, 명계왕 |
| healer | 55 | 10 | 5 | 성자, 대사제, 심판자 |
| caster | 40 | 14 | 3 | 현자, 대현자, 차원술사, 흑마법사 |
| assassin | 35 | 15 | 2 | 암살자, 환술사, 그림자군주 |
| tank | 60 | 9 | 7 | 수호자, 철벽성주, 암흑기사 |
| balanced | 45 | 11 | 5 | 방랑자, 조율사, 운명의 여행자, 만물일체 |

> 위 스탯은 **1층 기준**. 층별 배율 적용.

### 층별 스탯 배율

| 사망 층 | 배율 |
|---------|------|
| 1층 | ×1.0 |
| 2층 | ×1.3 |
| 3층 | ×1.6 |
| 4층 | ×1.85 |
| 5층 | ×2.1 |

예) 3층에서 사망한 암살자 유령: HP 35×1.6=56, ATK 15×1.6=24, DEF 2×1.6=3

### 원형별 행동 패턴

| 원형 | 기본 패턴 | 대체 패턴 수 |
|------|----------|-------------|
| attacker | attack, attack, charge, heavy | 2 |
| healer | heal, attack, defend, attack | 1 |
| caster | buff, charge, heavy, attack | 1 |
| assassin | attack, attack, attack, charge, heavy | 1 |
| tank | defend, defend, attack, charge, heavy | 1 |
| balanced | attack, defend, buff, attack | 1 |

### 카드 보상

유령 전투 승리 시 **유령 직업의 카드 풀**에서 보상 선택 (`rewardJobOverride`).
다른 직업 카드를 덱에 추가하여 하이브리드 빌드 가능.

- 1차 전직 직업: 해당 직업 카드 2장 + 무색 1장
- 2차 전직 직업: 카드 풀 없음 → 무색 카드 3장

---

## 소스 파일 참조

| 데이터 | 파일 |
|--------|------|
| 적 40종 정의 | `lib/domain/combat/content/floor_enemies.dart` |
| 적 풀/조회/변형 | `lib/domain/combat/content/enemy_pool.dart` |
| 보스 15종 정의 | `lib/domain/combat/content/boss_enemies.dart` |
| 보스 기믹 모델 | `lib/domain/combat/models/boss_combat_data.dart` |
| 보스 기믹 텍스트 | `lib/domain/combat/content/boss_gimmick_text.dart` |
| 적 행동 타입 | `lib/domain/combat/models/enemy_action_type.dart` |
| 적 AI | `lib/domain/combat/logic/enemy_ai.dart` |
| 데미지 계산 | `lib/domain/combat/logic/damage_calculator.dart` |
| 상태 효과 | `lib/domain/combat/models/status_effect.dart` |
| 행동 상호작용 | `lib/domain/combat/logic/action_interaction.dart` |
| 적 변형 모델 | `lib/domain/combat/models/enemy_modifier.dart` |
| 적 전투 상태 | `lib/domain/combat/models/enemy_battle_state.dart` |
| 멀티몹 조우 생성 | `lib/domain/combat/content/encounter_pool.dart` |
| 유령 전투 적 생성 | `lib/domain/progression/ghost/ghost_enemy_generator.dart` |
| 보스 조우 팩토리 | `lib/presentation/widgets/combat_ui/boss_encounter_factory.dart` |
| 보스 조우 JSON | `assets/content/boss_encounters.json` |
| 데모 전투 JSON | `assets/content/demo_encounters.json` |
| 보스 서사 텍스트 JSON | `assets/content/boss_text.json` |
| 전투 서사 텍스트 JSON | `assets/content/combat_text.json` |
