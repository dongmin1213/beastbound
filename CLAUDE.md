# BEASTBOUND

Flutter + Dart **몬스터 테이밍 덱빌더 로그라이크**. 모바일(iOS 15+ / Android 8.0+) + 웹, 오프라인 전용, 세로 모드.

> soul-dungeon(STS식 텍스트 로그라이크)을 포크해 만든 별개 게임. **폴더/레포명은 `beastbound`, 내부 Dart 패키지명은 `soul_dungeon` 유지**(import 전면 변경 회피). 프라이빗 레포: `github.com/dongmin1213/beastbound`.

---

## 핵심 컨셉

**"네가 싸운 적이, 네 덱이 된다."**

- **스타터 몬스터 1마리**로 시작 → 그 몬스터의 무브풀이 시작 덱.
- 적을 **제압**(HP ≤ 25%)한 뒤 **길들이면**(테이밍) 그 몬스터의 카드를 덱에 드래프트.
- 최대 **3마리 장착**(파티) → 장착 몬스터의 카드 풀 + 패시브 + 타입 친화가 적용.
- **보스 처치 = 강력한 동료 획득**(도감 등록 + 자동 장착).
- 메타: **도감 수집**(야수 + 영역의 주인) + 영구 강화(소울 상점).

**세계 전제:** 야수들이 깨어난 **심층**으로 내려가, 각 **영역의 주인**(상처 입은 강대한 야수 = 보스)을 제압해 파트너로 삼는 여정. 원작의 소울/구원 서사는 폐기.

**메타 서사:** 첫 유대(잃어버린 첫 파트너)에 집착하던 테이머가, 여러 유대를 죄책감 없이 순환시키는 법을 배운다. 5영역 감정 비트 = 첫만남 / 의존 / 명령 / 맹세 / 작별.

---

## 던전 구조

- **10층 = 5영역 × 2층.** 폐허(1-2) / 동굴(3-4) / 감옥(5-6) / 사원(7-8) / 심연(9-10).
- 각 영역: **첫 층(홀수) = 탐색 + 하위 주인(정예 보스)**, **둘째 층(짝수) = 영역의 주인(메인 보스)**.
- `FloorRegion.of(floor)` (core/config)로 층→지역 매핑. 바이옴/적 풀은 지역 단위 공유, HP는 층별 스케일링.
- 밸런싱: `assets/config/balance.json`의 `floors` 배열(10개) — HP 배율 1.0→2.3, 방 수 18→28.

---

## Tech Stack

- **Flutter 3.x stable** + **Dart 3** (sealed class 필수)
- **Flame** 1.37.0 — 전투 연출 씬(포켓몬식 씬-지배 구성)
- `flutter_bloc` 9.x / `go_router` / `flutter_soloud` / `flutter_svg` / `logger` / `shared_preferences` / `crypto` / `encrypt` / `flutter_animate`
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
5. **공유 모델은 `core/models/`**
6. **debug → `kDebugMode` 가드 필수**

---

## Bloc 규칙

- **3파일 분리:** `*_event.dart` + `*_state.dart` + `*_bloc.dart`
- **sealed class 필수:** 이벤트/상태 모두 → switch exhaustiveness
- **생성자 주입 only** — `context.read<T>()` Bloc 내부 사용 금지
- **도메인별 분리:** CombatBloc, MomentumBloc, DungeonBloc, RunBloc 등 — 단일 거대 Bloc 금지

---

## 몬스터 테이밍 시스템 (핵심 도메인)

| 요소 | 위치 | 역할 |
|------|------|------|
| 무브풀 | `domain/combat/content/monster_cards.dart` | 몬스터 id → 드래프트 가능 카드 id 목록 |
| 패시브 | `domain/combat/content/monster_passives.dart` | 매 턴 힘/방어/독/회복/드로우 + 타입(공격/방어/중독/회복/속공) + 타입 친화 |
| 도감 영속 | `core/config/tamed_monster_store.dart` | SharedPreferences 기반 길들인 몬스터 기록 |
| 테이밍 처리 | `presentation/screens/game/combat/card_combat_handler.dart` | 제압→길들이기→드래프트, 보스 승리→로스터 |
| 동료 관리 | `presentation/screens/game/widgets/party_manage_sheet.dart` | 최대 3마리 장착 (다음 전투부터 반영) |
| 스타터 선택 | `presentation/screens/starter/starter_select_screen.dart` | 시작 몬스터 = 시작 덱 |
| 도감 화면 | `presentation/screens/bestiary/bestiary_screen.dart` | 야수 + 영역의 주인 수집 표시 |

**콘텐츠 교체 원칙:** 무브풀 매핑(`monster_cards.dart`) 하나만 수정하면 덱 구성이 바뀐다(에셋 swap 철학).

---

## 제거된 원작 시스템 (전작 잔재 — 재도입 금지)

- **직업(JobPath) / 직업 분화(class change) / BuildBloc** — 스타터 몬스터가 대체. (물리 삭제 진행 중)
- **성향(DispositionAxis)** — 몬스터 패시브가 대체. 화면 표기 전면 제거됨.
- **유령(ghost) 시스템** — 삭제됨.
- **소울/구원 서사** — 야수 테이밍 서사로 대체.
- 신규 코드에서 위 시스템 참조/부활 금지. 남은 잔재는 발견 시 제거.

---

## 핵심 규칙

| 영역 | 규칙 |
|------|------|
| 서술자 왜곡 | **presentation only** — domain 실제 값 절대 변경 금지 |
| 에러 처리 | `Result<T>` 패턴 — `throw`/`catch` 남용 금지 |
| HSM 전환 | `tryTransition()` 경유만 |
| 콘텐츠 | Factory + ContentEngine 경유 — 하드코딩 생성 금지 |
| 파일 접근 | Config/Content 매니저 경유 — `File(...)` 직접 읽기 금지 |
| 로깅 | `GameLogger.log()` — `print()` 금지, 핫 패스 로깅 금지 |
| GameEvent | PascalCase + `Event` 접미사 |

---

## Anti-Patterns

| 금지 | 대안 |
|------|------|
| domain 간 직접 import | `core/models/` 또는 GameEventBus |
| Bloc 간 `.add()` 직접 호출 | `gameEventBus.emit()` |
| `context.read<T>()` Bloc 내부 | 생성자 주입 |
| 서술자 왜곡 → domain 값 변경 | presentation 표시값만 |
| 엔티티 하드코딩 생성 | Factory + ContentEngine |
| 파일 직접 읽기 `File(...)` | Config/Content 매니저 |
| `throw`/`catch` 남용 | `Result<T>` 패턴 |
| `print()` | `GameLogger.log()` |
| freezed | Dart 3 sealed class 직접 정의 |
| 직업/성향 시스템 재참조 | 몬스터 테이밍/패시브로 |
| 전작 어휘(던전 정복/소울 구원/전직) | 심층·영역·야생·유대·테이밍 |

---

## 네이밍

| 요소 | 패턴 | 예시 |
|------|------|------|
| 파일 | snake_case | `combat_bloc.dart` |
| 클래스 | PascalCase | `CombatBloc` |
| 함수/변수 | camelCase | `mapGesture()` |
| GameEvent | PascalCase + Event | `CombatVictoryEvent` |
| 테스트 | `*_test.dart` (1:1 미러링) | `combat_bloc_test.dart` |

---

## 테스트

- **미러링 1:1:** `lib/.../combat_bloc.dart` → `test/unit/.../combat_bloc_test.dart`
- **bloc_test**로 이벤트→상태 시퀀스 검증
- **Clock 추상화** + `fake_async`로 기세 감쇠 테스트
- **세이브:** active_slot 불일치 / JSON 파싱 실패 / 체크섬 불일치 3케이스
- 현재 기준: 약 2360 통과 + 사전존재 실패 5건(원작 포크 유래 이벤트/피드백 테스트 — 신규 실패 아님)

---

## ⚠️ 웹 테스트 (중요)

`flutter run -d web-server --web-port=812X` 로 구동. **이전에 릴리스 빌드를 돌린 포트(예 8123)는 서비스워커가 옛 빌드를 캐시**해서, `flutter clean`+CDP `Network.setCacheDisabled`+SW unregister를 해도 **옛 빌드를 서빙**한다(첫 로드가 SW를 거침). 반드시 **SW 이력 없는 새 포트**에서 검증할 것. 캔버스라 좌표 클릭이며 아이콘/노드 위치는 런마다 변동 → 매번 스크린샷으로 좌표 재확인.

---

## 설정 4계층

| 계층 | 저장 | 예시 |
|------|------|------|
| 게임 상수 | 코드 `const` | `FloorRegion.totalFloors` |
| 밸런싱 | `assets/config/balance.json` | `floors[].enemy_hp_multiplier` |
| 플레이어 설정 | `SharedPreferences` | 텍스트 크기/속도, 튜토리얼 표시, 길들인 몬스터 |

밸런싱 로드 시 값 범위 검증 필수 (실패 → 기본값 폴백 + 경고).

**콘텐츠 풀:** `assets/content/` JSON — `load({AssetBundle? bundle})` 비동기 + `_defaults` const 폴백 패턴. 실패 시 `_defaults` 유지. (기억 조각·보스 등)

---

## 상황별 힌트 / 튜토리얼

- `GameHintManager` (`core/config/game_hint_manager.dart`) — SharedPreferences 기반 1회 표시.

| 트리거 | 힌트 |
|--------|------|
| 첫 런 시작 | "심층으로 내려가 각 영역의 지배자를 쓰러뜨리는 것이 목표다. 제압한 적은 길들여 네 덱이 된다." |
| 테이밍 | "적 체력 25% 이하로 제압 → 길들이기 → 장착해 덱 구성" |
| 기세 첫 변동 | "다양한 행동을 할수록 올라간다. AP 증가" |
| 첫 사망/클리어 | "소울은 소울 상점에서 영구 강화에 사용" |
| 첫 정예방 | "일반 전투보다 강하지만 좋은 보상" |

- **전투 가이드 모달:** 앱 최초 전투 진입 1회 (`tutorial_combat_shown`).

---

## 성능 예산

60fps = 16.6ms: 텍스트 ~4ms + Bloc ~2ms + 오디오 ~1ms + UI ~4ms + 버퍼 ~5.6ms.
RAM 200MB 이하, 앱 50MB 이하, 콜드스타트 3초.

---

## 출시 정보

| 항목 | 내용 |
|------|------|
| 스토어 빌드 | `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info` |
| 문의 이메일 | justfun1213@naver.com |

> 개인정보 보호정책 등 스토어 메타는 원작(soul-dungeon)과 별개로 재작성 필요.
