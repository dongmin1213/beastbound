# Soul Dungeon

Flutter + Dart 텍스트 로그라이크 RPG. 모바일(iOS 15+ / Android 8.0+) + 웹, 오프라인 전용, 세로 모드.

상세 설계: `docs/DESIGN.md` · `docs/ARCHITECTURE.md` · `docs/JOBS.md` · `docs/ENEMIES.md` · `docs/CARDS.md` · `docs/ITEMS.md` · `docs/EVENTS.md` · `docs/META.md` · `docs/UI.md` · `docs/ART.md`

---

## Tech Stack

- **Flutter 3.x stable** + **Dart 3** (sealed class 필수)
- **Impeller** 렌더러 (iOS 기본, Android opt-in)
- `flutter_bloc` 9.x / `go_router` / `flutter_soloud` / `flutter_svg` / `logger` / `shared_preferences` / `crypto` / `encrypt`
- **freezed 미사용** — Dart 3 sealed class 직접 정의

---

## 아키텍처 경계 (절대 위반 금지)

```
core ← domain ← presentation
         ↑
       audio
```

1. **domain → core만 의존.** presentation 의존 금지
2. **domain 간 직접 import 금지** — `core/models/`만 예외
3. **시스템 간 통신은 GameEventBus만** — Bloc 간 `.add()` 직접 호출 금지
4. **HSM은 전환만 담당** — 내부 로직은 각 도메인 소유
5. **공유 모델은 `core/models/`** — 기존 `domain/shared/`에서 이전됨
6. **debug → `kDebugMode` 가드 필수**

---

## Bloc 규칙

- **3파일 분리:** `*_event.dart` + `*_state.dart` + `*_bloc.dart`
- **sealed class 필수:** 이벤트/상태 모두 → switch exhaustiveness
- **생성자 주입 only** — `context.read<T>()` Bloc 내부 사용 금지
- **도메인별 분리:** CombatBloc, MomentumBloc 등 — 단일 거대 Bloc 금지

---

## app.dart 동기화 규칙

- **`app.dart`는 GameScreen에 모든 Config/의존성을 전달하는 유일한 진입점.**
- **새 Config나 시스템을 GameScreen에 추가하면 반드시 `app.dart`도 함께 업데이트.**

---

## 핵심 규칙

| 영역 | 규칙 |
|------|------|
| 서술자 왜곡 | **presentation only** — domain 실제 값 절대 변경 금지 |
| 에러 처리 | `Result<T>` 패턴 — `throw`/`catch` 남용 금지 |
| HSM 전환 | `tryTransition()` 경유만 — 상태 직접 할당 금지 |
| 콘텐츠 | Factory + ContentEngine 경유 — 엔티티 하드코딩 생성 금지 |
| 파일 접근 | Config/Content 매니저 경유 — `File(...)` 직접 읽기 금지 |
| 로깅 | `GameLogger.log()` — `print()` 금지, 핫 패스 로깅 금지 |
| GameEvent | PascalCase + `Event` 접미사 |

---

## GameEventBus vs Bloc

| 상황 | 사용 |
|------|------|
| UI 리빌드 | Bloc (`BlocBuilder`/`BlocListener`) |
| 게임 로직 통신 | GameEventBus (도메인 간) |

---

## Anti-Patterns

| 금지 | 대안 |
|------|------|
| domain 간 직접 import | `core/models/` 또는 GameEventBus |
| Bloc 간 `.add()` 직접 호출 | `gameEventBus.emit()` |
| `context.read<T>()` Bloc 내부 | 생성자 주입 |
| 서술자 왜곡 → domain 값 변경 | presentation 표시값만 |
| HSM 상태 직접 할당 | `tryTransition()` |
| 엔티티 하드코딩 생성 | Factory + ContentEngine |
| 파일 직접 읽기 `File(...)` | Config/Content 매니저 |
| `throw`/`catch` 남용 | `Result<T>` 패턴 |
| `print()` | `GameLogger.log()` |
| 단일 파일 Bloc | 3파일 분리 |
| `go_router` 게임 내부 전환 | HSM 담당 (go_router는 최상위만) |
| 핫 패스 로깅 | 상태 전환 시점에만 |
| freezed | Dart 3 sealed class 직접 정의 |
| `bloc.add()` 후 `.state` 읽기 | state 먼저 읽고 add() |
| 테스트 `if (finder.evaluate().isNotEmpty)` | `expect(finder, findsOneWidget)` 후 tap |

---

## 네이밍

| 요소 | 패턴 | 예시 |
|------|------|------|
| 파일 | snake_case | `combat_bloc.dart` |
| 클래스 | PascalCase | `CombatBloc` |
| 함수/변수 | camelCase | `mapGesture()` |
| 상수 | lowerCamelCase | `maxFloors` |
| GameEvent | PascalCase + Event | `CombatVictoryEvent` |
| 테스트 | `*_test.dart` (1:1 미러링) | `combat_bloc_test.dart` |

---

## 테스트

- **미러링 1:1:** `lib/domain/combat/bloc/combat_bloc.dart` → `test/unit/domain/combat/bloc/combat_bloc_test.dart`
- **bloc_test**로 이벤트→상태 시퀀스 검증
- **Clock 추상화** + `fake_async`로 기세 감쇠 테스트
- **HSM:** 모든 valid 전환 + invalid 전환 → false 확인
- **세이브:** active_slot 불일치, JSON 파싱 실패, 체크섬 불일치 3케이스

---

## 설정 4계층

| 계층 | 저장 | 예시 |
|------|------|------|
| 게임 상수 | 코드 `const` | `GameConstants.maxFloors` |
| 밸런싱 | `assets/config/balance.json` | `BalanceConfig.bossHpMultiplier` |
| 플레이어 설정 | `SharedPreferences` | 텍스트 크기/속도, `tutorial_combat_shown` |
| 서비스 설정 | 미정 | 가격 모델 확정 시 |

밸런싱 로드 시 값 범위 검증 필수 (실패 → 기본값 폴백 + 경고)

**콘텐츠 풀:** `assets/content/` JSON 17종.
- **풀 JSON 9종** (축복/유물/저주/기억/엔딩/미스터리/성향/보스/데모): `load({AssetBundle? bundle})` 비동기 + `_defaults` const 폴백. `rootBundle.loadString()` → `jsonDecode()` → `_items` 교체. 실패 시 `_defaults` 유지.
- **서사 텍스트 JSON 8종** (boss_text/combat_text/meta_text/floor_1~5): `TextBlockSchema.fromJson()` 기반. ContentQuery 역인덱스 조회.

---

## 성능 예산

60fps = 16.6ms: 텍스트 ~4ms + Bloc ~2ms + 오디오 ~1ms + UI ~4ms + 버퍼 ~5.6ms
RAM 200MB 이하, 앱 50MB 이하, 콜드스타트 3초

---

## 튜토리얼

- **전투 가이드 모달:** 앱 최초 전투 진입 시 1회만 표시 (`SharedPreferences: tutorial_combat_shown`)
- `CombatTutorialModal` — `RetroWindowFrame` 스타일, `TutorialText.steps` 7단계 표시
- 이후 런/전투에서는 자동 스킵

---

## 도움말 시스템

- **상태효과 설명 팝업:** 전투 중 뱃지 탭 → `StatusEffectHelpPopup` (중첩 수 + 상세 설명)
- **카드 상세보기:** 롱프레스 또는 상태화면 덱 목록 탭 → `CardDetailOverlay` (키워드 설명 포함)
- **카드 키워드 설명:** `CardKeyword.description` — 소진/선천/영체/유지 효과 설명 (카드 상세보기에 표시)
- **전투 중 캐릭터 상태:** 액션 버튼 옆 `?` 아이콘 → `_showStatusDialog()` (유물/축복/덱/성향 전체)
- **탐색/상점/이벤트/휴식 중:** 👤 아이콘(미니맵 토글 바)으로 접근 — `DungeonRoomEntered`에서도 표시
- **보스 선택지 설명:** `BossChoiceType.description` — 6종 선택지 효과 설명 (선택 화면에 표시)
- **유물/축복 구매 설명:** 구매 시 `→ 효과 설명` 인라인 표시 (상점 + NPC)

---

## 상황별 힌트 시스템

- `GameHintManager` (`core/config/game_hint_manager.dart`) — `SharedPreferences` 기반 1회 표시
- `main.dart`에서 `GameHintManager.init(prefs)` 초기화

| 트리거 | 힌트 | 키 |
|--------|------|-----|
| 첫 런 시작 | "던전 5층의 보스를 쓰러뜨리는 것이 목표다" | `hint_goal_shown` |
| 성향 첫 변화 | "직업 분화와 엔딩에 영향을 준다" | `hint_disposition_shown` |
| 기세 첫 변동 | "다양한 행동을 할수록 올라간다. AP 증가" | `hint_momentum_shown` |
| 첫 사망/클리어 | "소울은 소울 상점에서 영구 강화에 사용" | `hint_soul_shown` |
| 첫 정예방 | "일반 전투보다 강하지만 좋은 보상" | `hint_elite_shown` |

---

## 이벤트 결과 표시

- 이벤트 선택 후 `CompleteRoom` → 갈림길 전환 시 결과가 유실되지 않도록 **pending 패턴** 사용
- `GameRunController._pendingEventResultBlocks` → `clearCompletedBlocks()`에서 flush
- 골드/HP/성향/카드 강화/카드 제거/카드 습득 — 모든 결과를 한 블록으로 합쳐 갈림길 상단에 표시

---

## UI 규칙

- **타이틀 메뉴 터치 영역:** 텍스트 크기만큼만 (가로 전체 금지), 페이드인 완료(`opacity >= 1.0`) 전 터치 차단

---

## 출시 정보

| 항목 | 내용 |
|------|------|
| 개인정보 보호정책 URL | https://dongmin1213.github.io/soul-dungeon-privacy/ |
| 개인정보 보호정책 레포 | github.com/dongmin1213/soul-dungeon-privacy (public) |
| 문의 이메일 | justfun1213@naver.com |
| 스토어 빌드 | `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info` (AAB 권장) |
