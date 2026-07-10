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
- [x] 원작 포크
- [ ] **1단계: `CardCombatView` 위젯 추출** (전투 UI를 GameScreen에서 격리) ← 진행 중
- [ ] 2단계: 전투 씬 내부를 Flame `GameWidget`으로 교체 (파일럿)
- [ ] 3단계~: 멀티몹/보스/왜곡 연출, UI 리프레시, 차별화 콘텐츠

## 실행

```bash
flutter pub get
flutter run
flutter test
```
</content>
