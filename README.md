# Soul Dungeon: Reforged

원작 [`soul-dungeon`](../soul-dungeon) — 텍스트 카드 로그라이크 RPG (Flutter, 완성작) —을
**그래픽 중심으로 업그레이드한 별도 게임**. 검증된 전투 로직을 그대로 재사용하고,
전투 화면을 **Flame 게임 씬**으로 교체해 "텍스트 로그"를 "살아있는 연출형 전투"로 끌어올린다.

> 원작에서 포크됨 (2026-07). Dart 패키지명은 당분간 `soul_dungeon` 유지(대규모 rename은 후순위).

## 기획 문서

| 문서 | 내용 |
|------|------|
| [`docs/01_프로젝트_전략.md`](docs/01_프로젝트_전략.md) | 전략 · 코드전략 · 그래픽수준 · 엔진 · 스토어규정 · 로드맵 |
| [`docs/02_전투씬_통합지도.md`](docs/02_전투씬_통합지도.md) | 원작 전투 구조 분석 + Flame 교체 통합지점 + 파일럿 범위 |

원작 게임 설계 문서(`DESIGN.md`, `ART.md`, `JOBS.md` 등)도 `docs/`에 함께 있음.

## 진행 상황

- [x] 기획·통합 분석
- [x] 원작 포크 (analyze 에러 0 / 통합 테스트 120개 통과 확인)
- [x] **1단계: `CardCombatView` 위젯 추출** — 전투 UI를 GameScreen에서 격리 (동작 보존, 테스트 통과)
- [x] **2단계: 전투 씬 Flame `GameWidget` 파일럿** — 스프라이트 + 슬래시 VFX + 데미지 숫자 + 피격 플래시 + 화면 흔들림 (동작·시각 검증 완료)
- [ ] 3단계: 멀티몹/보스/상태효과 VFX + 스프라이트 상태 프레임(attack/hurt/death) + 왜곡 연출 ← 다음
- [ ] 4단계~: 카드 오버레이 UI, 탐색/상점 리프레시, 차별화 콘텐츠

### 1단계 결과
- `lib/presentation/screens/game/combat/card_combat_view.dart` 신규 (313줄) — 적/전투로그/플레이어/카드 4개 패널
- `game_screen.dart` 2667 → 2459줄, `build()`가 전투/탐색 두 갈래로 분리됨

### 2단계 파일럿 결과
- `combat/flame/` — `CombatFlameGame`(배경/레이아웃/화면흔들림) + `CombatActor`(idle호흡·런지·피격플래시·사망디졸브) + `FloatingNumber` + `SlashEffect`
- `combat/flame_combat_scene.dart` — `CombatBloc.stream` 구독 → 상태 diff → 애니 트리거 (domain 값 불변)
- `CardCombatView` 적 패널이 정적 초상화 대신 Flame 씬을 렌더
- **기존 정적 PNG를 새 프레임 없이** 트랜스폼/VFX로 살아 움직이게 함 → 통합 테스트 120개 통과
- 데모 하네스: `lib/dev/flame_scene_preview.dart` (`flutter run -t lib/dev/flame_scene_preview.dart -d chrome`)
- 스크린샷: [`docs/pilot/01_scene_idle.png`](docs/pilot/01_scene_idle.png) · [`docs/pilot/02_attack_juice.png`](docs/pilot/02_attack_juice.png)
- 다음: 스프라이트 상태별 프레임(attack/hurt/death) 추가 + 카드 플레이 UI를 씬 오버레이로

## 실행

```bash
flutter pub get
flutter run
flutter test
```
</content>
