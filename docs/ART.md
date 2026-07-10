# 픽셀 아트 레퍼런스

Skul 스타일 SD 다크 판타지 픽셀 아트. 에셋 75종 완료.

---

## 총괄 요약

| 카테고리 | 수량 | 캔버스 | 출력 크기 |
|----------|------|--------|-----------|
| 앱 아이콘 | 1 | 32×32 | 48~1024px |
| 직업 아이콘 | 9 | 24×24 | 72~144px |
| 몬스터 (일반+엘리트) | 40 | 32×32 | 96~192px |
| 보스 | 15 | 48×48 | 144~288px |
| UI 아이콘 | 6 | 16×16 | 48~96px |
| 카드 타입 아이콘 | 3 | 12×12 | 36~72px |
| 타이틀 로고 | 1 | 64×32 | — |

---

## 아트 디렉션

### 레퍼런스: Skul: The Hero Slayer

| 항목 | 스타일 |
|------|--------|
| 톤 | **다크 판타지 + 귀여운 SD** — 어두운 세계관, 사랑스러운 캐릭터 |
| 비율 | **머리:몸 = 2:1~3:1** (SD 비율) |
| 윤곽선 | **1px 검정 아웃라인** 필수 |
| 눈 | **밝게 빛나는 점 2개** — 캐릭터 인식 핵심 |
| 팔레트 | **저채도 + 포인트 발광색** |
| 디테일 | **최소 픽셀, 최대 표현** — 2~3px로 장비 표현 |
| 배경 | **단색 또는 방사형 그라데이션** |

### 금지 사항

- Anti-aliasing 금지 (NEAREST 스케일링만)
- 반투명 픽셀 금지 (A = 0 또는 255만, 글로우 예외)
- 1px 단독 픽셀 금지 (눈 하이라이트 예외)
- 4색 이상 그라데이션 금지 (base + shadow + highlight = 3색)
- 디더링 금지, 필로우 셰이딩 금지

---

## 기술 사양

### 스케일링

항상 `Image.NEAREST` — BILINEAR/LANCZOS 절대 금지.

### 출력 경로

```
앱 아이콘:     android/app/src/main/res/mipmap-{density}/ic_launcher.png
게임 에셋:     assets/pixel_art/{category}/{name}.png
프리뷰:       assets/pixel_art/preview/{name}_preview.png (512×512)
```

### 셰이딩 규칙

- 광원: 항상 좌상단 (10시 방향)
- 왼쪽/위 = 하이라이트 (JOB_HI)
- 오른쪽/아래 = 그림자 (JOB_SHADOW)
- 나머지 = 기본색 (JOB_BASE)

---

## 마스터 팔레트

### 공통 색상

| 이름 | RGB | 용도 |
|------|-----|------|
| OUTLINE | (10, 8, 15) | 윤곽선 |
| BG_DARK | (18, 14, 28) | 어두운 배경 |
| BG_MID | (30, 24, 45) | 중간 배경 |
| BONE_HI | (235, 225, 210) | 피부/뼈 하이라이트 |
| BONE_BASE | (200, 185, 165) | 피부/뼈 기본 |
| BONE_SHADOW | (145, 130, 110) | 피부/뼈 그림자 |
| BONE_DARK | (100, 85, 70) | 피부/뼈 깊은 그림자 |
| SOUL_WHITE | (220, 200, 255) | 소울 코어 |
| SOUL_BRIGHT | (160, 120, 255) | 소울 밝은 보라 |
| SOUL_MID | (120, 80, 200) | 소울 중간 |
| SOUL_FAINT | (80, 50, 150) | 소울 약한 빛 |
| EYE_CORE | (255, 255, 255) | 눈 중심 (순백) |
| EYE_BRIGHT | (160, 120, 255) | 눈 빛 (보라) |
| EYE_RED | (255, 60, 60) | 적 눈 |
| EYE_GREEN | (60, 255, 100) | 독/저주 눈 |
| EYE_GOLD | (255, 210, 60) | 엘리트/보스 눈 |
| METAL_HI | (200, 210, 220) | 금속 하이라이트 |
| METAL_BASE | (140, 150, 165) | 금속 기본 |
| METAL_SHADOW | (80, 85, 100) | 금속 그림자 |
| GOLD_HI | (255, 235, 140) | 골드 하이라이트 |
| GOLD_BASE | (220, 180, 50) | 골드 기본 |
| GOLD_SHADOW | (170, 120, 30) | 골드 그림자 |

### 직업별 테마 색상

각 직업 3톤(HI/BASE/SHADOW) + 포인트(ACCENT).

| 직업 | HI | BASE | SHADOW | ACCENT |
|------|-----|------|--------|--------|
| 전사 | (180,70,60) | (140,45,35) | (90,25,20) | (255,140,50) 불꽃 |
| 성자 | (240,230,200) | (200,185,140) | (150,130,90) | (255,245,180) 신성 |
| 현자 | (80,120,200) | (50,75,150) | (30,45,100) | (120,180,255) 마력 |
| 암살자 | (90,60,120) | (60,35,85) | (35,20,55) | (0,230,120) 독 |
| 수호자 | (120,150,180) | (80,100,135) | (45,60,90) | (180,220,255) 방패 |
| 방랑자 | (160,140,100) | (120,100,65) | (75,60,40) | (200,230,150) 바람 |
| 사신 | (120,30,40) | (80,15,25) | (45,8,15) | (255,50,80) 영혼 |
| 환술사 | (150,80,180) | (110,50,140) | (70,30,95) | (255,130,200) 환영 |
| 조율사 | (80,180,170) | (50,130,125) | (30,80,75) | (150,255,230) 조화 |

### 층별 색조

| 층 | BASE | ACCENT |
|----|------|--------|
| 1 하수도 | (90,100,70) | (140,160,80) |
| 2 지하 감옥 | (80,85,100) | (130,140,180) |
| 3 마나 광산 | (60,50,120) | (120,160,255) |
| 4 심연 사원 | (100,30,40) | (200,60,80) |
| 5 심층 던전 | (40,20,60) | (160,80,255) |

---

## 캐릭터 그리기 규칙 (24×24)

### 기본 비율

```
행  0~3  : 여백 / 소울 이펙트 / 모자 꼭대기
행  4~6  : 모자 / 후드 / 왕관
행  7~13 : 머리 (7행, 큰 머리)
행 14~15 : 목 / 망토 어깨
행 16~20 : 몸통 + 팔 (5행, 머리보다 좁음)
행 21~23 : 다리 / 발 / 여백
```

### 그리기 순서

1. 윤곽선 (OUTLINE) → 2. 기본색 (JOB_BASE) → 3. 그림자 (JOB_SHADOW) → 4. 하이라이트 (JOB_HI) → 5. 얼굴 (BONE_BASE) → 6. 눈 (EYE_CORE + EYE_BRIGHT)

### 눈 패턴

| 유형 | 구성 | 대상 |
|------|------|------|
| 기본 (2px) | EYE_BRIGHT × 2 | 대부분 캐릭터 |
| 빛나는 (3px) | EYE_CORE + EYE_BRIGHT | 보스/강조 |
| 위협적 | EYE_RED 교체 | 적대 몬스터 |
| 슬릿 (세로 1px) | EYE_BRIGHT + EYE_CORE | 도적/뱀 |

### 몸통 규칙

- 머리 너비의 60~70%
- 어깨 장식 1~2px
- 팔 = 몸 양 옆 1px 폭
- 다리 2개 분리 (중앙 1px 간격) 또는 로브 통으로

### 장비 표현

| 장비 | 픽셀 |
|------|------|
| 검 | 세로 3~4px (METAL_HI → BASE) |
| 방패 | 2×3 사각형 |
| 지팡이 | 세로 4px + 보석 1~2px |
| 단검 | 세로 2px |
| 낫 | L자 3px |
| 후드 | 머리 위+양옆 1px 확장 |
| 왕관 | 지그재그 3px (GOLD) |

---

## 에셋별 사양

### 직업 아이콘 (24×24 — 9종)

| 직업 | 특징 요소 | 주요 색상 |
|------|-----------|-----------|
| 전사 | 투구 + 검 | WARRIOR_ + METAL_ |
| 성자 | 후광 + 지팡이 | SAINT_ + GOLD_ |
| 현자 | 뾰족 모자 + 보석 지팡이 | SAGE_ + SAGE_ACCENT |
| 암살자 | 후드 + 좌우 단검 | ASSASSIN_ + METAL_ |
| 수호자 | 무거운 투구 + 큰 방패 | GUARDIAN_ + METAL_ |
| 방랑자 | 챙넓은 모자 + 망토 | WANDERER_ + ACCENT |
| 사신 | 뾰족 후드 + 대형 낫 | REAPER_ + ACCENT |
| 환술사 | 반가면 + 거울 조각 | ILLUSION_ + ACCENT |
| 조율사 | 양 갈래 장식 + 오브 | HARMONY_ + ACCENT |

### 몬스터 (32×32 — 40종)

- 층별 색조 통일
- 일반: 눈 = EYE_RED, 캔버스 60%
- 엘리트: 눈 = EYE_GOLD + GOLD_ 장식, 캔버스 80%

### 보스 (48×48 — 15종, 층별 3종)

| 보스 | 층 | 특징 |
|------|-----|------|
| 슬라임 왕 | 1 | 거대 슬라임 + 왕관, 내부 해골 |
| 하수도 악어 | 1 | 거대 악어, 하수도 파이프 |
| 쥐 군주 | 1 | 왕관 쓴 거대 쥐, 부하 쥐 떼 |
| 거미 군주 | 2 | 거대 거미, 거미줄, 알 주머니 |
| 간수장 | 2 | 거대 열쇠 다발, 갑옷 |
| 원혼 사형수 | 2 | 사슬, 유령 화염 |
| 오크 대장군 | 3 | 전쟁 갑옷 + 대형 도끼 |
| 수정 골렘 | 3 | 수정 몸체, 마나 코어 |
| 마나 폭주체 | 3 | 불안정한 마나 결정, 에너지 방출 |
| 뱀파이어 군주 | 4 | 귀족 망토, 송곳니, 박쥐 날개 |
| 대악마 | 4 | 뿔, 날개, 마법진 |
| 타락 대사제 | 4 | 타락한 법복, 어둠의 지팡이 |
| 던전 마스터 | 5 | 왕좌, 소울 코어, 다중 팔 |
| 공허의 군주 | 5 | 공허 갑옷, 차원 균열 |
| 차원 붕괴자 | 5 | 불안정 형체, 다차원 왜곡 |

---

## 에셋 파일 경로

```
assets/pixel_art/
├── jobs/          — 직업 아이콘 9종
├── monsters/
│   ├── floor1/    — 하수도 7종
│   ├── floor2/    — 지하 감옥 7종
│   ├── floor3/    — 마나 광산 7종
│   ├── floor4/    — 심연 사원 7종
│   └── floor5/    — 심층 던전 7종
├── bosses/        — 보스 15종
├── ui/            — UI 아이콘 6종 (soul, hp, ap, block, gold, key)
├── cards/         — 카드 타입 3종 (attack, skill, power)
├── title/         — 타이틀 로고
└── preview/       — 512px 프리뷰
```

### 생성 스크립트

```
tools/pixel_common.py       — 팔레트 + 유틸리티
tools/gen_part1_icons.py    — 앱 아이콘 + 직업 아이콘 9종
tools/gen_part2_monsters.py — 몬스터 초상화 40종
tools/gen_part3_bosses_ui.py — 보스 15종 + UI/카드/타이틀
```

---

## 체크리스트

- [ ] 모든 색상이 마스터 팔레트에서 가져왔는가?
- [ ] OUTLINE 1px 테두리가 전체를 감싸는가?
- [ ] 눈이 명확히 보이는가?
- [ ] 광원 방향이 좌상단인가?
- [ ] 반투명 픽셀이 없는가? (글로우 예외)
- [ ] NEAREST 스케일링만 사용했는가?
- [ ] 같은 직업/층 에셋과 색조 통일?
- [ ] SD 비율 (머리:몸 ≥ 2:1)?

---

## 소스 파일 참조

| 데이터 | 파일 |
|--------|------|
| 팔레트 + 유틸리티 | `tools/pixel_common.py` |
| 아이콘 생성 | `tools/gen_part1_icons.py` |
| 몬스터 생성 | `tools/gen_part2_monsters.py` |
| 보스/UI 생성 | `tools/gen_part3_bosses_ui.py` |
| 픽셀 아트 매핑 | `lib/presentation/widgets/pixel_art_assets.dart` |
| 에셋 등록 | `pubspec.yaml` (assets/pixel_art/) |

---

## 오디오 시스템

### 생성 방식

| 에셋 | 생성 도구 | 포맷 | 라이선스 |
|------|----------|------|---------|
| BGM 8종 | MusicGPT API (AI 생성) | OGG Vorbis, 120초 루프 | 로열티 프리 |
| SFX 33종 | ElevenLabs Sound Effects API (AI 생성) | OGG Vorbis, 0.5~3초 | 로열티 프리 |

원본 MP3: `.bgm_temp/` (BGM), `.bgm_temp/sfx_raw/` (SFX)
변환: `soundfile` 스트리밍 쓰기 (MP3 → 모노 → 노멀라이즈 → OGG)

---

## SFX (효과음) — 33종

다크 판타지 텍스트 로그라이크에 맞는 절제된 톤. 아케이드/밝은 판타지풍 배제.

### SFX 카테고리

| 카테고리 | ID | 설명 |
|---------|-----|------|
| **카드** | card_attack | 검 휘두름 (whoosh + noise impact) |
| | card_skill | 어둠 에너지 (rising noise sweep) |
| | card_power | 파워 충전 (droning noise + sub bass) |
| **전투** | combat_hit | 타격 임팩트 (noise burst) |
| | combat_block | 방패 블록 (metallic noise) |
| | combat_victory | 승리 차임 (resonant noise chords) |
| | combat_defeat | 패배 하강 (brown noise fade) |
| | player_hurt | 플레이어 피격 |
| | chain_combo | 연쇄 보너스 |
| **덱** | deck_shuffle | 셔플 (noise cascade) |
| | card_draw | 드로우 슬라이드 |
| | card_exhaust | 소멸 (noise dissolve) |
| **상태 효과** | status_poison | 독 부글부글 |
| | status_burn | 화상 치이익 |
| | status_buff | 버프 상승음 |
| | status_debuff | 디버프 하강음 |
| **게임 플로우** | heal | HP 회복 |
| | rest_heal | 휴식 방 힐 |
| | gold_gain | 골드 획득 |
| | shop_purchase | 상점 구매 |
| | event_choice | 이벤트 선택 |
| | room_enter | 방 입장 |
| | class_change | 전직 팡파르 |
| | boss_appear | 보스 등장 |
| | boss_choice | 보스 선택 |
| | turn_start | 턴 시작 알림 |
| **UI** | ui_select | 선택 클릭 |
| | ui_confirm | 확인 차임 |
| **기세** | momentum_up | 기세 상승 전환 |
| | momentum_down | 기세 하락 전환 |
| **서술자** | narrator_distortion | 왜곡 글리치 |
| | narrator_truth_reveal | 진실 차임 |
| | narrator_silence | 침묵 저주파 |

### SFX 중복 방지

- **카드 플레이 윈도우 (300ms):** CardPlayedEvent 후 상태효과/드로우/소멸/연쇄 SFX 억제
- **동일 SFX 쿨다운 (100ms):** 같은 SFX ID 연속 재생 방지
- **기세 티어 변경:** Low↔Mid↔High 전환 시에만 momentum_up/down 재생

---

## BGM — 8종

MusicGPT API 생성 → MP3 → OGG 변환 (120초, 크로스페이드 루프, 피크 -6dB).

| 파일 | 용도 | 분위기 |
|------|------|--------|
| exploration_floor1.ogg | 1층 탐색 | 습한 동굴 드론 |
| exploration_floor2.ogg | 2층 탐색 | 어둠의 심화 |
| exploration_floor3.ogg | 3층 탐색 | 왜곡 영역 |
| exploration_floor4.ogg | 4층 탐색 | 불의 고리 |
| exploration_floor5.ogg | 5층 탐색 | 공허의 끝 |
| combat_normal.ogg | 일반 전투 | 긴장 드론 |
| combat_elite.ogg | 엘리트 전투 | 고조 드론 |
| combat_boss.ogg | 보스 전투 | 위압 드론 |

---

### 오디오 소스 파일

| 데이터 | 파일 |
|--------|------|
| SFX AI 생성 | `.bgm_temp/generate_sfx_ai.py` (ElevenLabs API) |
| BGM 변환 | `.bgm_temp/convert_bgm.py` (MP3→OGG) |
| SFX 변환 | `.bgm_temp/convert_sfx.py` (MP3→OGG) |
| SFX ID→경로 매핑 | `lib/audio/engine/sfx_registry.dart` |
| BGM ID→경로 매핑 | `lib/audio/engine/bgm_registry.dart` |
| AudioBloc (구독) | `lib/audio/bloc/audio_bloc.dart` |
| SFX 에셋 | `assets/audio/sfx/` (33종 OGG) |
| BGM 에셋 | `assets/audio/music/` (8종 OGG) |
| 원본 MP3 | `.bgm_temp/` (BGM), `.bgm_temp/sfx_raw/` (SFX) |
