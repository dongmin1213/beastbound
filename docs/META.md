# 메타 시스템 레퍼런스

성향 6축 + 엔딩 5종 + 소울 경제 + 유령 NPC + 기억 15종 + 기세 + 서술자 왜곡.

---

## 총괄 요약

| 시스템 | 핵심 | 영속성 |
|--------|------|--------|
| 성향 6축 | 이벤트/보스 선택으로 축적, 직업 전직 결정 | 런 한정 |
| 엔딩 5종 | 5보스 선택 가중치 합산으로 분기 | 런 한정 (기록 영구) |
| 소울 | 영구 화폐, 사망/클리어 시 획득 | 영구 |
| 유령 NPC | 사망 캐릭터가 다음 런에 등장 | 영구 |
| 기억 조각 | 조건 달성 시 해금, 스토리 공개 | 영구 |
| 기세 | 0~100 실시간, AP/텍스트/오디오 영향 | 전투/방 단위 |
| 서술자 왜곡 | 층별 진행, 표시값만 왜곡 | 런 내 층별 |

---

## 성향 6축

| 축 | 의미 | 직업 | 준비 선택지 |
|----|------|------|-----------|
| struggle (투쟁) | 전투적 해결 | 전사, 사신 | prep_blessing |
| mercy (자비) | 용서/치유 | 성자 | prep_mercy |
| wisdom (지혜) | 분석/관찰 | 현자 | prep_relic |
| shadow (그림자) | 은밀/기만 | 암살자, 환술사 | prep_gold |
| will (의지) | 인내/수호 | 수호자 | prep_hp |
| harmony (조화) | 균형/공존 | 방랑자, 조율사 | prep_balanced |

- 이벤트/NPC/보스 선택 시 성향 +1~4
- 임계치 5 도달 시 자동 직업 분화 (starter_ 카드 → 직업 시작 덱 교체, 획득 카드 보존)
- 준비 페이즈 선택 시 초기 성향 +2

### 준비 페이즈 선택지 (6개 중 랜덤 3개)

| ID | 이름 | 보너스 | 성향 |
|----|------|--------|------|
| prep_gold | 노자금 | 골드 보너스 | shadow +2 |
| prep_hp | 튼튼한 육체 | HP 보너스 | will +2 |
| prep_blessing | 전투 준비 | 축복 1개 | struggle +2 |
| prep_relic | 유물 탐색 | 유물 1개 | wisdom +2 |
| prep_mercy | 치유의 기도 | HP 회복 | mercy +2 |
| prep_balanced | 균형잡힌 준비 | 다중 소보너스 | harmony +2 |

### 2차 전직 임계치

| 전직 유형 | 조건 |
|----------|------|
| 상위직 | 기반 직업 + 단일 축 ≥ 10 |
| 조합직 | 주축 ≥ 8 + 부축 ≥ 5 |

2차 전직은 1차 전직(임계치 5) 이후 성향이 계속 축적되어 자동 발동.

---

## 보스 승리 후 선택지

6개 중 랜덤 3개 표시: 공격적 1개 + 온건 2개.

### 공격적 풀 (항상 가능 — 1개 랜덤)

| 선택 | 축 | 엔딩 카테고리 |
|------|-----|-------------|
| **처치** (slay) | struggle +3 | slay |
| **흡수** (consume) | shadow +3 | slay |

### 온건 풀 (첫 번째 항상 해금 + 두 번째 기세 50+ 해금 — 2개 랜덤)

| 선택 | 축 | 엔딩 카테고리 |
|------|-----|-------------|
| **해방** (liberate) | mercy +3 | liberate |
| **봉인** (protect) | will +3 | liberate |
| **공존** (coexist) | harmony +3 | coexist |
| **깨달음** (study) | wisdom +3 | coexist |

---

## 엔딩 (5종)

5보스 선택의 엔딩 카테고리 가중치 합산.

| 엔딩 | 트리거 | 톤 |
|------|--------|-----|
| 처치 (slay) | slay 카테고리 우세 | 비극 |
| 해방 (liberate) | liberate 카테고리 우세 | 희망 |
| 공존 (coexist) | coexist 카테고리 우세 | 온기 |
| 히든 (hidden) | 3카테고리 모두 존재 + 5보스 + maxCount ≤ 2 | 해방 |
| 초월 (transcend) | 히든 조건 + 히든 직업 + 기억 12개+ | 근원의 결말 |

**동점 처리:** 4층 보스(뱀파이어 군주) 선택 우선.

---

## 소울 경제

### 화폐 체계

| 화폐 | 범위 | 소멸 |
|------|------|------|
| 골드 | 런 내 | 사망 시 소멸 |
| 기세 | 0~100 | 전투/방 단위 |
| 소울 | 영구 | 소멸 없음 |
| 기억 조각 | 영구 | 소멸 없음 |

### 소울 획득

- 사망 시: `층 × soulBaseGain`
- 클리어 시: `soulBaseGain × 10`
- 런 종료 시 **런 요약**(여정의 기록)에 획득 소울 표시

### 소울 업그레이드 (12종)

| ID | 이름 | 효과 | 기본가 | 최대 레벨 | 지수 |
|----|------|------|--------|----------|------|
| soul_starting_deck_upgrade | 단련된 검 | 시작 덱 업그레이드 | 30 | 1 | 1.5 |
| soul_max_hp_1 | 강인한 육체 I | 최대 HP +8 | 20 | 3 | 1.3 |
| soul_starting_gold | 숨겨진 노자 | 시작 골드 +20 | 25 | 2 | 1.3 |
| soul_unlock_card_whirlwind | 소용돌이 해금 | 카드 해금 | 40 | 1 | 1.5 |
| soul_unlock_card_meditation | 명상 해금 | 카드 해금 | 40 | 1 | 1.5 |
| soul_gain_boost | 영혼 친화 | 소울 획득 +20%/레벨 | 40 | 2 | 1.3 |
| soul_shop_discount | 단골 손님 | 상점 15% 할인/레벨 | 35 | 2 | 1.3 |
| soul_max_hp_2 | 강인한 육체 II | 최대 HP +12 (I 완료 후) | 60 | 1 | 1.5 |
| soul_starting_momentum | 전투의 감각 | 전투 시작 모멘텀 +10 | 30 | 2 | 1.3 |
| soul_elite_reward | 현상금 사냥꾼 | 엘리트 골드 보상 +30%/레벨 | 35 | 2 | 1.3 |
| soul_free_card_removal | 덱 정리술 | 층당 1회 무료 카드 제거 | 50 | 1 | 1.5 |
| soul_rest_heal | 깊은 휴식 | 휴식 회복량 +5%/레벨 | 25 | 2 | 1.3 |

- 가격 곡선: `basePrice × (level+1)^exponent`

### 경제 예상

```
1런 = 5층 × 10방 = 50방
전투방 ~40% = 20전투 (일반 17 + 엘리트 3)
예상 총 골드: 17×10 + 3×20 = 230G
카드 제거 35G × 2 + 구매 = 빠듯한 경제
런 종료 예상 덱: 10(시작) + 12(획득) - 3(제거) = 19장
```

---

## 유령 NPC

사망 캐릭터 → 유령 풀 등록 (최대 10, FIFO) → 다음 런에 등장.

### 스폰 규칙

| 조건 | 확률 |
|------|------|
| 2런차 2층 | 100% (첫 유령 확정) |
| 3런차+ | 30% 확률 |

### 반응 레벨 (코사인 유사도)

현재 성향 6축과 유령 성향 스냅샷의 코사인 유사도 계산.

| 레벨 | 유사도 | 반응 |
|------|--------|------|
| familiar | ≥ 0.7 | 친근한 반응 |
| curious | ≥ 0.3 | 호기심 반응 |
| distant | < 0.3 | 거리감 반응 |

### 선택지 (반응 레벨별)

| 레벨 | 선택지 |
|------|--------|
| familiar | 이야기를 나눈다 / 지식을 나눠받는다 / **겨뤄본다** / 작별을 고한다 |
| curious | 이야기를 나눈다 / **겨뤄본다** / 작별을 고한다 |
| distant | 조심스럽게 다가간다 / **도발한다** / 무시하고 지나간다 |

### 보상/리스크 (비전투 선택)

선택지별 보상과 리스크가 반응 레벨에 따라 독립적으로 판정.
- **보상:** HP 회복 / 기세 증가 / 골드 (랜덤)
- **리스크:** HP 손실 / 기세 리셋 (랜덤)

| 선택지 | 레벨 | 보상 확률 | 보상량 | 리스크 확률 | 리스크량 |
|--------|------|----------|--------|-----------|---------|
| ghost_talk | familiar | 80% | 8 | 10% | 5 |
| ghost_talk | curious | 50% | 6 | 20% | 5 |
| ghost_trade | familiar | 70% | 12 | 20% | 8 |
| ghost_farewell | familiar | 90% | 5 | 0% | 0 |
| ghost_farewell | curious | 40% | 5 | 0% | 0 |
| ghost_approach | distant | 30% | 8 | 30% | 8 |
| ghost_ignore | — | 없음 | — | 없음 | — |

### 유령 PvP 전투

"겨뤄본다" / "도발한다" 선택 시 유령과 카드 전투 개시.

- **전투 타입:** 엘리트 (`RoomType.elite`)
- **적 생성:** `GhostEnemyGenerator.generate(ghost)` — 유령 직업 → 6가지 전투 원형 → 스탯 + 패턴
- **카드 보상:** 유령의 직업 카드 풀에서 선택 (`rewardJobOverride`) — 하이브리드 덱빌딩 가능
- **2차 전직 직업 유령:** 카드 풀이 없으므로 무색 카드 3장으로 폴백

상세 스탯/패턴은 `ENEMIES.md` 유령 전투 섹션 참조.

### 저장 데이터

`MetaSaveData.ghostNpcPoolRaw` — `List<Map<String, dynamic>>`

| 필드 | 타입 | 설명 |
|------|------|------|
| deathFloor | int | 사망 층 |
| jobId | String | 사망 시 직업 ID |
| dispositionSnapshot | Map<String, int> | 성향 6축 스냅샷 |
| runNumber | int | 사망 런 번호 |

---

## 기억 조각 (15장)

4범주: 기원(origin), 상실(loss), 유대(bond), 순환(cycle).

- 조건 달성 시 해금
- "그 사람" 정체 점진 공개
- 휴식 방 "기억 탐색"으로 확인 (비소비)
- 초월 엔딩 조건: 12개 이상 해금

---

## 기세 (Momentum)

### 기본 설정

| 설정 | 값 |
|------|----|
| 범위 | 0~100 |
| 초기값 | 30 (Mid 시작, AP 3 보장) |
| 감쇠 | 미구현 (설계: 1/초, 5초 딜레이) |
| Low 임계 | 0~29 |
| Mid 임계 | 30~79 |
| High 임계 | 80~100 |

### 기세 변동

| 원인 | 변동 |
|------|------|
| 다른 타입 카드 플레이 | +12 |
| 환경 카드 플레이 | +20 |
| 같은 타입 연속 (공격 카드) | 감소 |
| 공격 3연쇄+ 달성 | +10 |

### 기세 영향

| 시스템 | Low | Mid | High |
|--------|-----|-----|------|
| **AP** | 2 | 3 | 4 |
| TextEngine | 느림 | 기본 | 빠름 |
| Audio | 기본 | 활기 | 강렬 |
| Choice | 제한 | 기본 | 온건 해금 |
| Narrator | 높은 신뢰 | 기본 | 낮은 신뢰 |

### 티어 효과 상호작용

| 기세 | effective | neutral | ineffective |
|------|-----------|---------|-------------|
| High | enhanced | enhanced | neutral |
| Mid | effective | neutral | ineffective |
| Low | neutral | diminished | diminished |

---

## 서술자 왜곡

**핵심 원칙:** domain 값 절대 불변. presentation 표시값만 왜곡.

### 층별 왜곡 단계

| 층 | 상태 | 왜곡 수준 |
|----|------|-----------|
| 1 | NarratorReliable | 투명 (왜곡 없음) |
| 2 | NarratorDistorted | 미세 징조 (glitch 확률 5%, HP 오프셋 0) |
| 3 | NarratorDistorted | 카드 왜곡 레벨 1, HP 오프셋 ±3 |
| 4 | NarratorDistorted | 카드 왜곡 레벨 2, HP 오프셋 ±5 |
| 5 | NarratorDistorted | 카드 왜곡 레벨 2, HP 오프셋 ±5, **침묵** |

### 왜곡 규칙

- **숫자 왜곡 (3층~):** 데미지/블록 수치 변조
- **AP 비용 표시 왜곡**
- **타입/이름은 항상 정직** — 타입 왜곡은 즉사 사유
- **분석(현자):** 3턴간 모든 카드 진실 표시 (`truthRevealTurnsRemaining`)
- **기억된 카드:** 3회+ 사용 카드는 왜곡 불가

---

## 히든 직업 해금

| 직업 | 조건 클래스 | 요구 사항 |
|------|-----------|----------|
| 사신 (reaper) | TotalWinsCondition | 총 3회 클리어 |
| 환술사 (illusionist) | WinWithJobCondition | 암살자로 1회 클리어 |
| 조율사 (harmonist) | TotalWinsCondition | 총 5회 클리어 |

`JobUnlockChecker.checkNewUnlocks()` → 기록 대비 조건 검증 → 신규 해금 ID 반환.

---

## 난이도 곡선

톱니형: 층 내 점진 상승 → 보스 정점 → 다음 층 완화.
4층: 파워 판타지 구간 (빌드 완성 체감).

### 저주 레벨 (클리어 후)

| 레벨 | 칭호 | 적 힘 보너스 | 보상 감소 | 상점 배율 | 저주 카드 | 서술자 오프셋 |
|------|------|-----------|----------|----------|----------|-------------|
| 0 | 기본 | 0 | 0 | ×1.0 | 0장 | 0층 |
| 1 | 도전자 | +2 | 0 | ×1.0 | 0장 | 0층 |
| 2 | — | +3 | 0 | ×1.3 | 1장 | 1층 |
| 3 | 정복자 | +5 | -1 | ×1.5 | 1장 | 1층 |
| 4 | — | +7 | -1 | ×1.7 | 2장 | 2층 |
| 5 | 전설 | +10 | -1 | ×2.0 | 2장 | 2층 |

---

## 소스 파일 참조

| 데이터 | 파일 |
|--------|------|
| 성향 6축 enum | `lib/core/models/disposition_axis.dart` |
| 준비 페이즈 선택 | `lib/domain/build/logic/prep_phase.dart` |
| 보스 선택 6종 | `lib/core/models/boss_choice.dart` |
| 엔딩 5종 타입 | `lib/domain/ending/ending_types.dart` |
| 엔딩 텍스트 JSON | `assets/content/endings.json` |
| 엔딩 텍스트 로더 | `lib/domain/ending/ending_text_content.dart` |
| 엔딩 분기 로직 | `lib/domain/ending/ending_resolver.dart` |
| 소울 계산 | `lib/domain/progression/soul/soul_calculator.dart` |
| 소울 업그레이드 풀 | `lib/domain/progression/soul/soul_upgrade_pool.dart` |
| 소울 업그레이드 모델 | `lib/domain/progression/soul/soul_upgrade_data.dart` |
| 유령 NPC 생성 | `lib/domain/progression/ghost/ghost_npc_generator.dart` |
| 유령 NPC 데이터 | `lib/domain/progression/ghost/ghost_npc_data.dart` |
| 유령 반응 레벨 | `lib/domain/progression/ghost/ghost_reaction.dart` |
| 유령 전투 적 생성 | `lib/domain/progression/ghost/ghost_enemy_generator.dart` |
| 유령 보상/리스크 판정 | `lib/domain/progression/ghost/ghost_reward_resolver.dart` |
| 유령 텍스트/선택지 | `lib/presentation/screens/game/ghost/ghost_text_builder.dart` |
| 유령 상호작용 핸들러 | `lib/presentation/screens/game/ghost/ghost_interaction_handler.dart` |
| NPC 방 핸들러 (유령 통합) | `lib/presentation/screens/game/rooms/npc_room_handler.dart` |
| 히든 직업 해금 | `lib/domain/progression/unlock/job_unlock_registry.dart` |
| 해금 체커 | `lib/domain/progression/unlock/job_unlock_checker.dart` |
| 2차 전직 판정 | `lib/domain/build/logic/class_change_detector.dart` |
| 기세 계산 | `lib/domain/momentum/logic/momentum_calculator.dart` |
| 기세 Bloc | `lib/domain/momentum/bloc/momentum_bloc.dart` |
| 기세 타입 | `lib/core/models/momentum_types.dart` |
| 티어 효과 | `lib/core/models/tier_effect_calculator.dart` |
| 서술자 Bloc | `lib/domain/narrative/bloc/narrator_bloc.dart` |
| 서술자 상태 | `lib/domain/narrative/bloc/narrator_state.dart` |
| 런 상태 모델 | `lib/core/models/player_run_state.dart` |
| 진행 Bloc | `lib/domain/progression/bloc/progression_bloc.dart` |
| 성향 힌트 JSON | `assets/content/disposition_hints.json` |
| 성향 힌트 생성 | `lib/presentation/screens/game/disposition_hint_generator.dart` |
| 기억 조각 JSON | `assets/content/memory_fragments.json` |
| 기억 조각 풀 | `lib/domain/progression/memory/memory_fragment_pool.dart` |
| 저주 레벨 설정 | `assets/config/balance.json` (curses 섹션) |
| 메타 서사 텍스트 JSON | `assets/content/meta_text.json` |
| 서사 텍스트 스키마 | `lib/domain/narrative/models/text_block_schema.dart` |
| 서사 콘텐츠 쿼리 | `lib/domain/narrative/content/content_query.dart` |
