# Soul Dungeon - Architecture

## Tech Stack

| 기술 | 버전 | 용도 |
|------|------|------|
| Flutter | 3.x stable | 프레임워크 |
| Dart 3 | Flutter 내장 | sealed class 필수 |
| Impeller | iOS 기본, Android opt-in | 렌더러 |
| flutter_bloc | 9.x | 상태 관리 |
| go_router | stable | 최상위 네비게이션만 |
| flutter_soloud | ^3.4.10 | 4레이어 오디오 (SoLoudSoundLayerManager) |
| logger | stable | 구조화 로그 |
| shared_preferences | stable | 플레이어 설정 |
| crypto | stable | SHA-256 체크섬 |
| encrypt | ^5.0.3 | AES-256-CBC 세이브 암호화 |
| flutter_svg | ^2.2.3 | 카드 아이콘 SVG 렌더링 |
| flutter_animate | ^4.5.2 | UI 애니메이션 (stagger, shimmer, fadeIn) |
| NotoSansKR (번들) | Variable | 한글 폰트 (assets/fonts/) |

**플랫폼:** iOS 15+ / Android 8.0+ / Web, 오프라인, 세로 모드

### 빌드 환경

| 항목 | 경로 |
|------|------|
| Flutter | `/c/src/flutter/bin/flutter.bat` |
| Android SDK | `/c/Users/DamonKim/Android/Sdk` |

릴리즈 빌드: `ANDROID_HOME=/c/Users/DamonKim/Android/Sdk /c/src/flutter/bin/flutter.bat build apk --release`

---

## Architecture Decisions

| # | 결정 | 핵심 |
|---|------|------|
| D1 | Bloc 패턴 | flutter_bloc 9.x + Dart 3 sealed class, 3파일 분리, freezed 미사용 |
| D2 | Custom HSM | 4계층 `Run→Floor→Room→Phase`, `tryTransition()` 경유만, 직접 할당 금지 |
| D3 | 더블 버퍼 세이브 | 비활성 슬롯 쓰기 → SHA-256 → active_slot 커밋, emergency_save 3번째 슬롯 |
| D4 | Content Engine | 역인덱스 `Map<String, Set<int>>`, 태그 Set intersection O(1), 가중 랜덤 |
| D5 | 입력 시스템 | 탭=진행/선택, 롱프레스=상세, 카드=ChoiceRouter + 2탭 확인 |
| D6 | Result\<T\> | critical(emergency_save) / recoverable(폴백) / warning(로그만) |
| D7 | 4단계 테스트 | 유닛(bloc_test) → 위젯 → 통합 → 골든패스 |
| D8 | GoRouter | `/ → /game → /settings`, 게임 내부 전환은 HSM 담당 |
| D9 | 콘텐츠 JSON 분리 | 하드코딩 콘텐츠 풀 → `assets/content/` JSON + `_defaults` 폴백 |

---

## Novel Patterns

| # | 패턴 | 설명 |
|---|------|------|
| N1 | Text-as-Mechanic | 텍스트 속도/스타일/신뢰도 자체가 메카닉. JamoDecomposer 한글 자모 분리 |
| N2 | Unreliable Narrator | 1층 투명 → 2층 후반 미세 징조 → 3층 본격화 → 4~5층 심화. presentation only, domain 불변 |
| N3 | Ghost NPC | 사망 캐릭터 → 성향 스냅샷 → 코사인 유사도 L1/L2/L3 반응 |

---

## Project Structure

```
lib/
├── core/             # 인프라 (error, events, logging, save, config, input, clock)
├── domain/
│   ├── # (shared/ → core/models/로 이전됨)
│   ├── hsm/          # 상태 머신 (Run→Floor→Room→Phase)
│   ├── combat/       # 전투 (bloc/ + models/ + logic/)
│   ├── momentum/     # 기세 (bloc/ + logic/)
│   ├── narrative/    # 서사 (bloc/ + content/ + models/)
│   ├── build/        # 캐릭터 빌드 (성향/직업/시너지/저주/유물/희귀도)
│   ├── run/          # 런 상태 (RunBloc — HP/골드/PlayerRunState)
│   ├── dungeon/      # 던전 (generator/ + shop/ + npc/ + rest/ + event/ + mystery/)
│   ├── progression/  # 메타 (ghost/ + soul/ + memory/)
│   └── ending/       # 엔딩 분기 (EndingResolver → 5가지 엔딩)
├── presentation/     # UI (screens/ + widgets/ + theme/ + PathDescriptionGenerator + PixelArtAssets)
└── audio/            # 오디오 (bloc/ + engine/SoLoudSoundLayerManager + SFX 33종 Kenney CC0)
```

## Dependency Direction (절대 규칙)

```
core ← domain ← presentation
         ↑
       audio

domain 간 직접 import 금지 → core/models/ 또는 GameEventBus만
```

---

## Cross-Cutting

**GameEventBus:** UI 리빌드 → Bloc, 도메인 간 통신 → GameEventBus. 히스토리 링 버퍼 50개, dirty flag 캐싱.

**Momentum:** 0~100, 임계값 10/30/80, 감쇠 1/sec(5초 딜레이). 영향: AP(핵심), TextEngine, Audio, Choice, Narrator.

**Audio Engine:** `SoLoudSoundLayerManager` (flutter_soloud ^3.4.10). SFX fire-and-forget + Music 단일 트랙 루프. Master → `setGlobalVolume()`, 레이어별 per-handle 볼륨. SFX 33종 OGG preload (ElevenLabs AI 생성), BGM 8종 (MusicGPT AI 생성). 모든 SoLoud 호출 try-catch — 오디오 실패로 앱 크래시 없음. 테스트 시 `NoOpSoundLayerManager` DI 주입.

---

## Data Models (핵심 구조)

> 상세 필드는 소스코드 참조.

| 모델 | 위치 | 핵심 |
|------|------|------|
| CardData | `core/models/card_data.dart` | id, name, jobId?, type, apCost, effects |
| CardEffect | 상동 | type(CardEffectType enum 135값), value, condition?, duration? |
| CardCombatActive | `domain/combat/bloc/combat_state.dart` | 34필드 + TurnFlags(8) + PowerEffects(9) 하위 객체 |
| DeckState | 상동 | drawPile, hand, discardPile, exhaustPile |
| CardBlessingData | `core/models/` | 33종, 9 trigger |
| CardRelicData | `core/models/` | 8종, 7 trigger |
| CurseModifierData | `core/models/` | 4종(combat/deck/card/narrator), level 0~5 |
| BossCombatData | `domain/combat/models/` | 15보스, 다단계 BossPhaseConfig, 10기믹 |
| EnemyBattleState | `domain/combat/models/` | 적별 가변 전투 상태 (HP/블록/힘/상태효과), 멀티몹 지원 |
| EnemyModifier | `domain/combat/models/` | 5종 접두사 수식어 (강화/맹독/분노/단단/신속) |
| EncounterPool | `domain/combat/content/` | 멀티몹 조우 생성 (1~3체, HP 70~80% 스케일링) |
| SaveEncryptor | `core/save/` | AES-256-CBC, PBKDF2, ENC: 마커, 비암호화 역호환 |
| PixelArtAssets | `presentation/widgets/` | 적/보스/직업 ID → 픽셀 아트 스프라이트 경로 매핑 |
| CombatFlowManager | `presentation/widgets/combat_ui/` | 전투 UI 텍스트 블록 생성 + 런 요약(Run Summary) 빌더 |
| SoulShopScreen | `presentation/screens/soul_shop/` | 소울 업그레이드 상점 UI (타이틀→라우팅) |
| JobUnlockChecker | `domain/progression/` | 히든 직업 해금 조건 검증 |

---

## Multi-Floor & Save

- 5층 톱니형 난이도, `FloorsConfig` + `withFloorOverride()` 머지
- SaveManager: 더블 버퍼 + SHA-256, 자동 저장(층 전환 + 백그라운드)
- 퍼마데스: run 삭제 + meta 사망 기록 + **런 요약(Run Summary) 표시**
- 보스 페이즈 전환: `CardBossPhaseTransition` 상태에 `activeBlessings`/`activeRelics` 보존 → Phase 2 첫 턴 즉시 턴 시작 효과 적용
- 엔딩: 5보스 선택 누적 → slay/liberate/coexist/hidden/transcend
- app.dart = 유일한 DI 진입점 (economyConfig → 각 핸들러 DI 포함)

| 데이터 | 영속성 | 퍼마데스 시 |
|--------|--------|-------------|
| Meta (소울, 유령, 기억, 엔딩) | 영구 | 유지 + 사망 기록 |
| Run (층/방, HP, 기세, 성향, 덱) | 런 한정 | 삭제 |

---

## Performance

60fps = 16.6ms: 텍스트 ~4ms + Bloc ~2ms + 오디오 ~1ms + UI ~4ms + 버퍼 ~5.6ms
RAM 200MB 이하, 앱 50MB 이하, 콜드스타트 3초.

| 최적화 | 효과 |
|--------|------|
| CardPool.findById → Map 인덱스 | O(n) → O(1) |
| GameEventBus.history → dirty flag | 매 조회 toList() 제거 |
| ContentEngine → LRU 16 캐시 | 반복 교집합 제거 |
| DeckManager.draw → List.of + addAll | 불필요 복사 제거 |
| PathFinder → rooms > 15 역추적 DFS | 경로 수 폭발 방지 |

---

## Content JSON (D9)

하드코딩 콘텐츠 풀을 `assets/content/` JSON으로 분리. 앱 초기화 시 `load()` 호출.
실패 시 코드 내 `_defaults` const로 폴백 — JSON 없이도 동작 보장.

### 풀 JSON (9종)

| JSON 파일 | 풀 클래스 | 콘텐츠 |
|-----------|----------|--------|
| `blessings.json` | BlessingPool | 축복 18종 (상점+NPC+악마) |
| `relics.json` | RelicPool | 유물 14종 |
| `curses.json` | CursePool | 저주 10 + 악마축복 4 + 거래 14 |
| `memory_fragments.json` | MemoryFragmentPool | 기억 조각 15종 |
| `endings.json` | EndingTextContent | 엔딩 텍스트 5종 |
| `mystery_texts.json` | MysteryResultGenerator | 미스터리 방 텍스트 22종 |
| `disposition_hints.json` | DispositionHintGenerator | 성향 힌트 18종 |
| `boss_encounters.json` | BossEncounterFactory | 보스 조우 5층 + 폴백 |
| `demo_encounters.json` | Combat/Elite/BossDemoEncounter | 데모 전투 3종 |

### 서사 텍스트 JSON (8종)

`TextBlockSchema.fromJson()` 기반. `ContentQuery` 역인덱스로 조건별 텍스트 조회.

| JSON 파일 | 콘텐츠 |
|-----------|--------|
| `boss_text.json` | 보스 전투 서사 텍스트 |
| `combat_text.json` | 일반/엘리트 전투 서사 텍스트 |
| `meta_text.json` | 층 전환/엔딩/유령 서사 텍스트 |
| `floor_1.json` ~ `floor_5.json` | 층별 방 서사 텍스트 (5종) |

**패턴:**
```dart
static List<T> _items = _defaults;
static List<T> get items => _items;

static Future<void> load({AssetBundle? bundle, String path}) async {
  try { /* JSON 로드 → _items 교체 */ }
  catch (e) { /* 로그 + _items = _defaults */ }
}
```

---

## Logging

`[timestamp] [LEVEL] [System] message` — 핫 패스 금지, 상태 전환 시점만.
릴리스: ERROR+WARN만. `print()` 금지 → `GameLogger.log()`.
