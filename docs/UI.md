# UI 디자인 시스템 레퍼런스

컬러 팔레트 + 폰트 + 간격 + 전투 레이아웃 + 카드 디자인 + 주요 위젯.

---

## 총괄 요약

| 항목 | 규칙 |
|------|------|
| 컬러 | 다크 남색 배경 + 타입별 포인트 컬러 |
| 폰트 | Noto Sans KR (google_fonts), ResponsiveScale 경유 |
| 간격 | 8px 기반 그리드 |
| 레이아웃 | 3단 구성: 적(상) + 로그(중) + 카드(하) |
| 카드 | 110×160px, 2탭 확인, 3-stop 그라디언트 |
| 층별 테마 | FloorThemeVisuals — 프레임/버튼/타이틀바 색상 층별 적용 |
| 에셋 | game-icons.net SVG 107종 + 픽셀 아트 75종 |

---

## 컬러 팔레트

| 용도 | Hex | 비고 |
|------|-----|------|
| 배경 (탐색) | `#0E0E18` | 미세 밝은 남색 |
| 배경 (전투) | `#0A0A14` | 깊은 남색 |
| 카드 배경 | `#12122A` | |
| Attack 카드 | `#E53935` | 하단 바 + 테두리 |
| Skill 카드 | `#66BB6A` | |
| Power 카드 | `#AB47BC` | |
| AP 사용 가능 | `#FFD54F` | 금색 다이아몬드 |
| AP 부족 | `#E53935` | 카드 비활성 |
| HP 게이지 | `#E53935` | 30% 이하 깜빡임 |
| 적 HP | `#FF7043` | 주황 |
| 데미지 텍스트 | `#EF5350` | |
| 회복 텍스트 | `#66BB6A` | |
| 블록 텍스트 | `#42A5F5` | |
| 연쇄 보너스 | `#FF9800` | 오렌지 |

---

## 폰트

| 영역 | 스타일 | 크기 |
|------|--------|------|
| 전체 | Noto Sans KR (google_fonts) | — |
| 서술 본문 | Regular | 14sp |
| 카드 이름 | Bold | 13sp |
| 카드 효과 | Regular | 12sp |
| HUD 수치 | Monospace | 12sp |
| 상태효과 뱃지 | Monospace Bold | 10sp |

모든 폰트는 `ResponsiveScale.scaleFontSize()` 경유. 하드코딩 금지.

---

## 간격 (8px 기반)

| 상수 | 값 | 용도 |
|------|----|------|
| spacingXs | 4px | 아이콘 간격 |
| spacingSm | 8px | 카드 내부, HUD 패딩 |
| spacingMd | 16px | 섹션 간격, 화면 패딩 |
| spacingLg | 24px | 주요 블록 간격 |
| spacingXl | 32px | 화면 영역 분리 |

---

## 층별 테마 (FloorThemeVisuals)

`lib/presentation/theme/floor_theme_visuals.dart` — 층 번호에 따라 UI 전체 색상 변경.

### 적용 범위

- **RetroWindowFrame:** titleBarColor, backgroundColor → 층별 combatUiTint, frameBackground
- **PlayerStatusBar:** backgroundColor → 층별 frameBackground
- **전투 버튼:** 턴 종료/도주 버튼 배경·테두리 → 층별 색상
- **선택지 영역:** 배경 → 3-stop 그라디언트 페이드 (상단 투명 → 하단 불투명)
- **미니맵 / 상태 화면:** frameBackground, titleBarColor → 층별
- **방 위젯 전부:** 상점, 미스터리, 이벤트, NPC, 휴식, 기억 탐색 — frameBackground 전달

### 층별 컬러

| 층 | 테마 | frameBackground | combatUiTint | 분위기 |
|----|------|-----------------|--------------|--------|
| 1 | 잊힌 지하도 | `#0B120D` (어두운 녹) | `#1A2E1E` | 습한 동굴, 초록 톤 |
| 2 | 깊은 어둠 | `#0A0D16` (짙은 남색) | `#1A1A2E` | 기본 다크 블루 |
| 3 | 왜곡 영역 | `#0E0B18` (보라 암색) | `#241A2E` | 마법 왜곡, 보라 톤 |
| 4 | 불의 고리 | `#14100B` (갈색 암색) | `#2E1E1A` | 화염·용암, 갈색 톤 |
| 5 | 공허의 끝 | `#090914` (심연 남색) | `#1E1A2E` | 최종 공허, 깊은 보라 |

### 턴 종료 / 도주 버튼 (층별)

| 층 | 턴 종료 BG | 턴 종료 Border | 도주 BG | 도주 Border |
|----|-----------|---------------|---------|------------|
| 1 | `#1A3E2A` | `#4AAA7A` | `#1E2A1A` | `#6B8B53` |
| 2 | `#1A2A3E` | `#4A7AAA` | `#2A1A1A` | `#8B5533` |
| 3 | `#2A1A3E` | `#7A4AAA` | `#2A1A2A` | `#8B5583` |
| 4 | `#3E2A1A` | `#AA7A4A` | `#2E1A16` | `#8B5533` |
| 5 | `#241A3E` | `#6A5AAA` | `#221A24` | `#6B5583` |

---

## 전투 레이아웃

```
┌──────────────────────────────────────┐
│  HP 88/100 [████████░░]   3턴       │  ← HUD
│  AP ◆◆◇◇   [독2][취약1]            │  ← 플레이어 상태 뱃지
├──────────────────────────────────────┤
│           슬라임 왕                   │  ← 적 영역
│      [██████░░░░] 51/60             │     (이름 + HP + 의도 + 상태)
│      공격 12   [독1]                 │
├──────────────────────────────────────┤
│  ═══════ 3턴 ═══════                │  ← 전투 로그 (축소, 최근 N줄)
│  분쇄로 12 데미지! 적에게 취약 1.    │
├──────────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌────  │  ← 카드 핸드
│  │ ◆2   │ │ ◆1   │ │ ◆1   │ │ ◆2  │
│  │ 분쇄 │ │ 타격 │ │ 방어 │ │ ..  │
│  │10dmg │ │ 6dmg │ │ 5blk │ │     │
│  │█████ │ │█████ │ │█████ │ │████ │
│  └──────┘ └──────┘ └──────┘ └────  │
├──────────────────────────────────────┤
│  덱 12  [ 턴 종료 ]  버림 3         │  ← 덱/버림 카운터 + 액션
└──────────────────────────────────────┘
```

3단 구성: 적 영역(상단) + 전투 로그(중단, 축소) + 카드 핸드(하단, 확대).

### 멀티몹 적 표시 + 타겟 선택

멀티몹 전투(2~3체) 시 적 영역을 2열 그리드로 배치. 1마리는 기존 세로 레이아웃, 2마리는 가로 1줄(2열), 3마리는 2+1 배치. 각 적마다 이름, HP 게이지, 의도, 상태효과 뱃지를 개별 표시. 선택된 적은 노란 테두리로 표시.

- **타겟 선택 UI**: 단일 대상 카드 사용 시 2체 이상 생존이면 타겟 선택 UI 활성화. 적 영역의 개별 적을 탭하여 대상을 지정한 뒤 카드를 실행한다.
- **AoE 카드**: 타겟 선택 없이 모든 생존 적에게 즉시 적용.
- **사망 적**: HP 0 이하 적은 흐리게(opacity 감소) 표시 후 퇴장.
- **보상 화면**: 전투 승리 후 보상 선택 시 턴 종료/도주 버튼 숨김. 건너뛰기는 카드 핸드 아래 풀 너비 버튼으로 분리 배치.

### 연쇄 보너스 연출

공격 카드 연속 사용 시 연쇄 보너스 텍스트 표시:
- 메인 텍스트에 총 데미지(연쇄 포함) 표시: "N 데미지! (연쇄 +X)"
- 2연쇄: 오렌지 테두리 배지 "2연쇄! 드로우 +1"
- 3연쇄+: 오렌지 테두리 배지 "3연쇄! 드로우 +1 / 기세 +10"

연쇄 텍스트는 `CompletedBlockRenderer._buildChain()` 렌더링.
시너지(3연쇄+)는 `_buildSynergy()` — 골드(combatVictoryColor).

---

## 카드 디자인

```
┌──────────────┐
│ ◆ 2    [전체]│  ← AP 다이아몬드 16px (좌상단) + AoE 배지 (우상단, 전체 대상 카드만)
│              │
│    ⚡ (glow)  │  ← SVG 아이콘 48sp + radial glow
│              │
├──────────────┤  ← 타입색 상단 구분선 (0.4 opacity)
│  ██ 분쇄 ██  │  ← 카드명 (white, Bold, typeColor glow)
│  10 데미지   │  ← 효과 텍스트 (12sp, #CCCCCC)
│   [사용]     │  ← 선택 시만 표시 (typeColor)
│██████████████│  ← 하단 타입 바 (6px, typeColor 그라디언트)
└──────────────┘
```

- 카드 110×160px (ResponsiveScale 적용)
- 5장 이하 중앙 정렬, 6장 이상 가로 스크롤 + 힌트 화살표
- 2탭 확인: 1차=선택(scale 1.08x + glow), 2차=실행(slideY + fadeOut)
- 3-stop LinearGradient: `[cardGradientTop, cardGradientTop*0.7, cardBackground]`

---

## 런 요약 (Run Summary)

모든 런 종료 시점(사망/클리어)에 표시되는 "여정의 기록" 블록:

```
══════ 여정의 기록 ══════

직업: 전사
도달: 3층

덱: 15장 (제거 2장)
축복: 3개  유물: 2개  저주: 0개
골드: 87

보스 선택: 1층 처치, 2층 해방

획득 소울: 30
════════════════════════
```

- `CombatFlowManager.buildRunSummaryBlock()` 에서 생성
- 적용 지점: 카드 전투 사망, 텍스트 전투 사망, 보스 승리/엔딩, 이벤트 방 사망, 미스터리 방 사망

---

## 조작

| 입력 | 동작 |
|------|------|
| 탭 | 선택, 텍스트 진행 |
| 스와이프 | 빠른 탐색, 텍스트 스크롤 |
| 롱프레스 | 중요 선택 확인 (보스 선택지, 악마의 거래) |

---

## 에셋

| 종류 | 수량 | 라이선스 |
|------|------|---------|
| game-icons.net SVG | 107종 | CC BY 3.0 |
| Noto Sans KR | OFL | via google_fonts |
| 픽셀 아트 | 75종 | 자체 제작 |
| SFX | 33종 | AI 생성 (ElevenLabs) OGG |
| BGM | 8종 | AI 생성 (MusicGPT) OGG |

코드 처리: 미니맵 심볼, 배경 tint, CRT 비네트, 모든 연출.

---

## 주요 위젯

| 파일 | 역할 |
|------|------|
| `widgets/choice/choice_card_widget.dart` | 카드/선택지 |
| `widgets/choice/choice_list_widget.dart` | 카드 핸드/선택지 리스트 + 스크롤 힌트 |
| `widgets/choice/card_icon_mapper.dart` | 카드 ID → SVG 매핑 (107종) |
| `widgets/completed_block_renderer.dart` | 완료 블록 렌더러 (연쇄/시너지 연출) |
| `widgets/combat_ui/combat_hud_widget.dart` | 전투 HUD (HP/AP/적HP) |
| `widgets/combat_ui/combat_outcome_widget.dart` | 전투 결과 (shimmer/shake) |
| `widgets/combat_ui/gauge_bar.dart` | 게이지 바 (HP/적HP 공용) |
| `widgets/effects/vignette_overlay.dart` | CRT 비네트 |
| `widgets/effects/retro_window_frame.dart` | 레트로 OS 프레임 |
| `widgets/effects/floor_transition_overlay.dart` | 층 전환 연출 |
| `widgets/minimap/minimap_widget.dart` | 미니맵 ("모험가의 메모") |
| `screens/game/game_screen.dart` | 메인 게임 화면 |
| `screens/title/title_screen.dart` | 타이틀 화면 |
| `screens/soul_shop/soul_shop_screen.dart` | 소울 상점 화면 |
| `widgets/combat_ui/combat_flow_manager.dart` | 전투 텍스트 블록 + 런 요약 빌더 |
| `theme/app_theme.dart` | 테마 상수 + 간격 그리드 |
| `theme/floor_theme_visuals.dart` | 층별 컬러 테마 (5층) |
| `theme/responsive_scale.dart` | 반응형 스케일 (폰트/패딩/수직) |

모든 경로는 `lib/presentation/` 기준.

---

## 소스 파일 참조

| 데이터 | 파일 |
|--------|------|
| 테마 상수/컬러 | `lib/presentation/theme/app_theme.dart` |
| 반응형 스케일 | `lib/presentation/theme/responsive_scale.dart` |
| 카드 위젯 | `lib/presentation/widgets/choice/choice_card_widget.dart` |
| 카드 아이콘 매핑 | `lib/presentation/widgets/choice/card_icon_mapper.dart` |
| 전투 HUD | `lib/presentation/widgets/combat_ui/combat_hud_widget.dart` |
| 게임 화면 | `lib/presentation/screens/game/game_screen.dart` |
| 타이틀 화면 | `lib/presentation/screens/title/title_screen.dart` |
| 소울 상점 | `lib/presentation/screens/soul_shop/soul_shop_screen.dart` |
| 런 요약 빌더 | `lib/presentation/widgets/combat_ui/combat_flow_manager.dart` |
| 픽셀 아트 매핑 | `lib/presentation/widgets/pixel_art_assets.dart` |
| 상태효과 설명 팝업 | `lib/presentation/widgets/combat_ui/status_effect_help_popup.dart` |
| 카드 상세 오버레이 | `lib/presentation/widgets/combat_ui/card_detail_overlay.dart` |

---

## 도움말 시스템

| 기능 | 트리거 | 위치 |
|------|--------|------|
| 전투 튜토리얼 | 앱 최초 전투 진입 시 1회 | `CombatTutorialModal` |
| 상태효과 설명 | 뱃지 탭 | `StatusEffectHelpPopup` — RetroWindowFrame, 중첩 수 + 상세 설명 |
| 카드 상세보기 | 카드 롱프레스 / 상태화면 덱 카드 탭 | `CardDetailOverlay` — AP/데미지/블록/키워드 설명/효과 |
| 카드 키워드 설명 | 카드 상세보기 내 | `CardKeyword.description` — 소진/선천/영체/유지 효과 설명 |
| 캐릭터 상태 열기 | 탐색 중: 👤 / 전투 중: ? / 상점·이벤트·휴식: 👤 | `StatusScreenWidget` — 덱/유물/축복/저주/성향 전체 확인 |
| 보스 선택지 설명 | 보스 승리 후 선택 화면 | `BossChoiceType.description` — 6종 선택지 효과 인라인 표시 |
| 유물/축복 구매 설명 | 상점/NPC 구매 시 | `item.description` 인라인 표시 ("→ 효과 설명") |
| 상황별 힌트 (5종) | 각 시스템 첫 조우 시 1회 | `GameHintManager` — SharedPreferences 기반 |

- `StatusEffectType.description` — 8종 상태효과(힘/민첩/독/화상/약화/취약/가시/재생) 상세 설명 텍스트
- `CardKeyword.description` — 4종 키워드(소진/선천/영체/유지) 상세 설명 텍스트
- `BossChoiceType.description` — 6종 보스 선택지(처치/해방/공존/깨달음/흡수/봉인) 설명 텍스트
- 상태효과 뱃지(`StatusEffectBadgesWidget`)는 `GestureDetector`로 탭 시 팝업 표시
- 이벤트 결과(골드/HP/카드 강화/습득/제거)는 `appendEventResultText` pending 패턴으로 갈림길 화면에 표시
