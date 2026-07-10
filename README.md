# 몬스터 테이밍 덱빌더 (작업명 TBD)

원작 [`soul-dungeon`](../soul-dungeon)(STS식 덱빌딩 로그라이크, Flutter)의 **장르 엔진만 계승한
신규 모바일 게임**. 세계관·시그니처·콘텐츠·아트는 새로 설계.

> **컨셉:** "네가 싸운 적이, 네 덱이 된다." 적을 죽이지 않고 **제압**해 **길들이면**
> 그 몬스터의 카드 패키지가 덱이 된다. 도감 수집 = 메타 진행.
>
> 원작에서 포크됨 (2026-07). 초기엔 "그래픽 업그레이드판"으로 시작했다가
> **신규 게임 컨셉으로 전환**(장르 엔진만 유지). Dart 패키지명은 당분간 `soul_dungeon` 유지.

## 기획 문서

| 문서 | 내용 |
|------|------|
| [`docs/04_컨셉_몬스터테이밍.md`](docs/04_컨셉_몬스터테이밍.md) | **★ 현재 컨셉** — 제압/길들이기, 덱 융합, 도감, 재사용 vs 신규 |
| [`docs/03_에셋_교체_가이드.md`](docs/03_에셋_교체_가이드.md) | 아트 swap-ready 구조 + AI 아트 사양 |
| [`docs/01_프로젝트_전략.md`](docs/01_프로젝트_전략.md) | 코드전략 · 엔진 · 스토어규정 · 원작 재복제 정책 (초기 프레이밍) |
| [`docs/02_전투씬_통합지도.md`](docs/02_전투씬_통합지도.md) | 원작 전투 구조 분석 + Flame 통합지점 |

원작 게임 설계 문서(`DESIGN.md`, `ART.md`, `JOBS.md` 등)도 `docs/`에 함께 있음(장르 엔진 참고용).

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
- **화면 구성 개편(포켓몬 골드식):** 대각선 대치(적 우상단 / 플레이어 좌하단·크게) + 발판 원근 +
  코너 HP 플레이트(적 좌상단 / 플레이어 우하단) + 하단 명령창(메시지+카드). 전투기록·손패 패널 제거로 공간 효율↑
- 스크린샷: `docs/pilot/` — `05_pokemon_layout_idle.png` · `06_pokemon_layout_attack.png` (세로/폰)
- 다음: 이 씬-지배 구성을 실제 `CardCombatView`에 이식(현재는 적 밴드에 고정높이 배치) + 스프라이트 상태 프레임(attack/hurt/death)

## 실행

```bash
flutter pub get
flutter run
flutter test
```
</content>
