"""Part 1: 앱 아이콘(개선) + 직업 아이콘 9종 (고유 실루엣)."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from pixel_common import *

# ============================================================
# 앱 아이콘 (32x32) — 후드 해골 + 소울 불꽃 (개선)
# ============================================================
def draw_app_icon():
    img = create_sprite(32, 32)
    # 원형 배경 (보라빛 그라데이션)
    filled_circle(img, 15, 15, 15, BG_DARK)
    filled_circle(img, 15, 16, 12, BG_MID)
    filled_circle(img, 14, 15, 8, (38, 30, 55, 255))

    # 후드 (둥근 형태, 보라 계열)
    H_B = SOUL_MID; H_H = SOUL_BRIGHT; H_S = SOUL_FAINT
    # 후드 꼭대기 (둥글게)
    hline(img, 11, 19, 7, OUTLINE)
    hline(img, 10, 20, 8, OUTLINE)
    hline(img, 12, 18, 8, H_B)
    hline(img, 9, 21, 9, OUTLINE)
    hline(img, 10, 20, 9, H_B)
    hline(img, 10, 14, 9, H_H)
    # 후드 본체
    for y in range(10, 18):
        put(img, 8, y, OUTLINE); put(img, 22, y, OUTLINE)
        hline(img, 9, 21, y, H_B)
    # 후드 셰이딩
    vline(img, 9, 10, 16, H_H)
    hline(img, 9, 13, 10, H_H)
    vline(img, 21, 10, 17, H_S)
    hline(img, 17, 21, 17, H_S)
    # 후드 하단 넓어짐
    put(img, 7, 17, OUTLINE); put(img, 23, 17, OUTLINE)
    hline(img, 8, 9, 17, H_S); hline(img, 21, 22, 17, H_S)

    # 얼굴 (해골 — 둥근 형태)
    hline(img, 10, 20, 12, OUTLINE)
    for y in range(13, 21):
        hline(img, 9, 21, y, BONE_BASE)
    hline(img, 10, 20, 21, OUTLINE)
    vline(img, 9, 13, 20, OUTLINE); vline(img, 21, 13, 20, OUTLINE)
    put(img, 10, 12, OUTLINE); put(img, 20, 12, OUTLINE)
    # 얼굴 셰이딩
    hline(img, 10, 15, 13, BONE_HI)
    vline(img, 10, 13, 17, BONE_HI)
    hline(img, 16, 20, 20, BONE_SHADOW)
    vline(img, 20, 17, 20, BONE_SHADOW)

    # 눈구멍 (큰, 표현력 있게)
    rect(img, 11, 14, 13, 17, OUTLINE)
    rect(img, 17, 14, 19, 17, OUTLINE)
    # 눈 발광 (코어 + 주변)
    put(img, 12, 15, EYE_CORE); put(img, 12, 16, EYE_BRIGHT)
    put(img, 11, 15, EYE_BRIGHT); put(img, 13, 16, EYE_BRIGHT)
    put(img, 18, 15, EYE_CORE); put(img, 18, 16, EYE_BRIGHT)
    put(img, 17, 15, EYE_BRIGHT); put(img, 19, 16, EYE_BRIGHT)

    # 코 (역삼각형)
    put(img, 15, 17, BONE_SHADOW)
    put(img, 14, 18, BONE_SHADOW); put(img, 16, 18, BONE_SHADOW)

    # 이빨 (톱니 모양)
    hline(img, 12, 18, 19, OUTLINE)
    for x in [12, 14, 16, 18]:
        put(img, x, 20, BONE_HI)
    for x in [13, 15, 17]:
        put(img, x, 20, OUTLINE)

    # 소울 불꽃 (머리 위, 더 역동적)
    put(img, 15, 3, SOUL_WHITE)
    put(img, 14, 4, SOUL_BRIGHT); put(img, 15, 4, SOUL_WHITE); put(img, 16, 4, SOUL_BRIGHT)
    put(img, 13, 5, SOUL_MID); put(img, 14, 5, SOUL_BRIGHT); put(img, 15, 5, SOUL_WHITE)
    put(img, 16, 5, SOUL_BRIGHT); put(img, 17, 5, SOUL_MID)
    put(img, 14, 6, SOUL_MID); put(img, 15, 6, SOUL_BRIGHT); put(img, 16, 6, SOUL_MID)
    put(img, 15, 7, SOUL_FAINT)
    # 불꽃 꼬리
    put(img, 12, 5, SOUL_FAINT); put(img, 18, 5, SOUL_FAINT)
    put(img, 13, 4, SOUL_FAINT); put(img, 17, 4, SOUL_FAINT)

    # 브로치 (골드)
    put(img, 15, 22, GOLD_HI)
    put(img, 14, 22, GOLD_BASE); put(img, 16, 22, GOLD_BASE)
    put(img, 15, 23, GOLD_SHADOW)

    # 원형 테두리
    outline_circle(img, 15, 15, 15, OUTLINE)
    return img

# ============================================================
# 직업별 고유 실루엣 (24x24) — 각각 독립적으로 그림
# ============================================================

def draw_warrior():
    """전사: 넓은 어깨 + 뿔 투구 + 대검."""
    img = create_sprite(24, 24)
    W = WARRIOR_BASE; WH = WARRIOR_HI; WS = WARRIOR_SHADOW; WA = WARRIOR_ACCENT
    # 투구 (둥글고 장식적)
    hline(img, 8, 15, 3, OUTLINE)
    for y in range(4, 8):
        put(img, 7, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 8, 15, y, W)
    hline(img, 8, 12, 4, WH); vline(img, 8, 4, 7, WH)
    hline(img, 12, 15, 7, WS); vline(img, 15, 4, 7, WS)
    # T자 슬릿
    hline(img, 9, 14, 6, METAL_HI)
    vline(img, 11, 6, 8, METAL_HI); vline(img, 12, 6, 8, METAL_HI)
    # 뿔 (양쪽 돌출, 굵게)
    put(img, 6, 4, WA); put(img, 5, 3, WA); put(img, 5, 2, OUTLINE)
    put(img, 6, 3, OUTLINE)
    put(img, 17, 4, WA); put(img, 18, 3, WA); put(img, 18, 2, OUTLINE)
    put(img, 17, 3, OUTLINE)
    # 얼굴
    hline(img, 7, 16, 8, OUTLINE)
    rect(img, 8, 8, 15, 12, BONE_BASE)
    hline(img, 8, 12, 8, BONE_HI); vline(img, 8, 8, 11, BONE_HI)
    hline(img, 12, 15, 12, BONE_SHADOW); vline(img, 15, 9, 12, BONE_SHADOW)
    vline(img, 7, 8, 13, OUTLINE); vline(img, 16, 8, 13, OUTLINE)
    hline(img, 7, 16, 13, OUTLINE)
    # 눈
    put(img, 9, 10, EYE_CORE); put(img, 10, 10, EYE_BRIGHT)
    put(img, 13, 10, EYE_BRIGHT); put(img, 14, 10, EYE_CORE)
    # 넓은 어깨 갑옷 (전사만의 넓은 실루엣)
    hline(img, 5, 18, 13, OUTLINE)
    rect(img, 5, 14, 18, 15, METAL_BASE)
    hline(img, 6, 12, 14, METAL_HI)
    hline(img, 12, 17, 15, METAL_SHADOW)
    vline(img, 4, 14, 15, OUTLINE); vline(img, 19, 14, 15, OUTLINE)
    # 몸통 (갑옷)
    rect(img, 8, 16, 15, 20, W)
    vline(img, 8, 16, 20, WH); vline(img, 15, 16, 20, WS)
    hline(img, 8, 15, 20, WS)
    vline(img, 7, 16, 21, OUTLINE); vline(img, 16, 16, 21, OUTLINE)
    hline(img, 7, 16, 21, OUTLINE)
    # 벨트
    hline(img, 8, 15, 19, GOLD_SHADOW)
    put(img, 11, 19, GOLD_HI); put(img, 12, 19, GOLD_HI)
    # 대검 (오른쪽, 크고 굵게)
    vline(img, 20, 3, 20, METAL_HI)
    vline(img, 21, 3, 20, METAL_BASE)
    put(img, 20, 2, METAL_BASE); put(img, 21, 2, METAL_BASE)
    put(img, 19, 11, GOLD_BASE); put(img, 22, 11, GOLD_BASE)
    put(img, 20, 11, GOLD_HI); put(img, 21, 11, GOLD_HI)
    vline(img, 20, 12, 14, WARRIOR_BASE); vline(img, 21, 12, 14, WARRIOR_SHADOW)
    # 다리
    rect(img, 8, 21, 10, 23, WS); rect(img, 13, 21, 15, 23, WS)
    put(img, 8, 23, OUTLINE); put(img, 10, 23, OUTLINE)
    put(img, 13, 23, OUTLINE); put(img, 15, 23, OUTLINE)
    return img

def draw_saint():
    """성자: 긴 로브 + 후광 + 신성한 지팡이."""
    img = create_sprite(24, 24)
    S = SAINT_BASE; SH = SAINT_HI; SS = SAINT_SHADOW; SA = SAINT_ACCENT
    # 후광 (머리 위 아치)
    for dx in range(-4, 5):
        put(img, 11+dx, 2, SA)
    put(img, 6, 3, SA); put(img, 16, 3, SA)
    put(img, 6, 2, SA); put(img, 16, 2, SA)
    # 머리 (둥근 후드)
    hline(img, 8, 14, 4, OUTLINE)
    for y in range(5, 8):
        put(img, 7, y, OUTLINE); put(img, 15, y, OUTLINE)
        hline(img, 8, 14, y, S)
    hline(img, 8, 11, 5, SH); vline(img, 8, 5, 7, SH)
    hline(img, 11, 14, 7, SS); vline(img, 14, 5, 7, SS)
    # 얼굴 (큰, SD)
    hline(img, 6, 16, 7, OUTLINE)
    for y in range(8, 14):
        put(img, 6, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 7, 15, y, S)
    hline(img, 6, 16, 14, OUTLINE)
    # 얼굴 하단
    rect(img, 8, 9, 14, 13, BONE_BASE)
    hline(img, 8, 11, 9, BONE_HI); vline(img, 8, 9, 12, BONE_HI)
    hline(img, 12, 14, 13, BONE_SHADOW); vline(img, 14, 10, 13, BONE_SHADOW)
    # 눈
    put(img, 9, 11, EYE_CORE); put(img, 10, 11, EYE_BRIGHT)
    put(img, 12, 11, EYE_BRIGHT); put(img, 13, 11, EYE_CORE)
    # 긴 로브 (A라인, 전사와 확연히 다른 실루엣)
    for y in range(14, 23):
        w = 3 + (y - 14) // 2
        cx = 11
        hline(img, cx-w, cx+w, y, S)
        put(img, cx-w-1, y, OUTLINE); put(img, cx+w+1, y, OUTLINE)
    hline(img, 5, 17, 23, OUTLINE)
    # 로브 셰이딩
    for y in range(15, 22):
        w = 3 + (y - 14) // 2
        put(img, 11 - w, y, SH)
        put(img, 11 + w, y, SS)
    # 로브 중앙선
    vline(img, 11, 15, 22, SS)
    # 성스러운 십자 장식
    put(img, 11, 16, GOLD_HI)
    put(img, 10, 17, GOLD_BASE); put(img, 11, 17, GOLD_HI); put(img, 12, 17, GOLD_BASE)
    put(img, 11, 18, GOLD_SHADOW)
    # 지팡이 (왼쪽)
    vline(img, 4, 4, 22, BONE_SHADOW)
    put(img, 4, 3, SA); put(img, 3, 4, SA); put(img, 5, 4, SA)
    put(img, 4, 2, SA)
    put(img, 4, 1, OUTLINE)
    return img

def draw_sage():
    """현자: 뾰족한 마법사 모자 + 지팡이 보석 + 로브."""
    img = create_sprite(24, 24)
    B = SAGE_BASE; BH = SAGE_HI; BS = SAGE_SHADOW; BA = SAGE_ACCENT
    # 뾰족 모자 (더 길고 날씬하게)
    put(img, 11, 0, OUTLINE)
    put(img, 11, 1, BH)
    put(img, 10, 1, OUTLINE); put(img, 12, 1, OUTLINE)
    for y in range(2, 6):
        w = min(y - 1, 3)
        hline(img, 11-w, 11+w, y, B)
        put(img, 11-w-1, y, OUTLINE); put(img, 11+w+1, y, OUTLINE)
    hline(img, 11-1, 11+1, 2, BH)
    # 모자 챙
    hline(img, 5, 17, 6, OUTLINE)
    hline(img, 6, 16, 6, B)
    hline(img, 6, 11, 6, BH)
    hline(img, 12, 16, 6, BS)
    hline(img, 5, 17, 7, OUTLINE)
    # 별 장식 (모자 끝)
    put(img, 11, 0, BA)
    # 머리
    for y in range(7, 14):
        put(img, 6, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 7, 15, y, B)
    hline(img, 6, 16, 14, OUTLINE)
    vline(img, 7, 7, 13, BH); vline(img, 15, 7, 13, BS)
    # 얼굴
    rect(img, 8, 9, 14, 13, BONE_BASE)
    hline(img, 8, 11, 9, BONE_HI); vline(img, 8, 9, 12, BONE_HI)
    hline(img, 12, 14, 13, BONE_SHADOW)
    # 눈
    put(img, 9, 11, EYE_CORE); put(img, 10, 11, BA)
    put(img, 12, 11, BA); put(img, 13, 11, EYE_CORE)
    # 로브 (약간 넓어지는)
    rect(img, 8, 14, 14, 20, B)
    vline(img, 7, 14, 21, OUTLINE); vline(img, 15, 14, 21, OUTLINE)
    vline(img, 8, 14, 20, BH); vline(img, 14, 14, 20, BS)
    hline(img, 7, 15, 21, OUTLINE)
    # 벨트
    hline(img, 8, 14, 18, BS)
    put(img, 11, 18, BA)
    # 지팡이 (오른쪽, 보석 큼)
    vline(img, 19, 3, 21, BONE_SHADOW)
    # 보석 (3x3 다이아몬드)
    put(img, 19, 1, BA); put(img, 18, 2, BA); put(img, 20, 2, BA)
    put(img, 19, 2, EYE_CORE); put(img, 19, 3, BA)
    put(img, 19, 0, OUTLINE); put(img, 17, 2, OUTLINE); put(img, 21, 2, OUTLINE)
    # 마법 파티클
    put(img, 20, 0, BA); put(img, 17, 1, BA)
    # 다리 (로브 밑)
    put(img, 9, 21, BS); put(img, 10, 21, BS)
    put(img, 12, 21, BS); put(img, 13, 21, BS)
    return img

def draw_assassin():
    """암살자: 날렵한 실루엣 + 큰 후드 + 쌍단검."""
    img = create_sprite(24, 24)
    A = ASSASSIN_BASE; AH = ASSASSIN_HI; AS_ = ASSASSIN_SHADOW; AA = ASSASSIN_ACCENT
    # 큰 뾰족 후드
    put(img, 11, 2, OUTLINE)
    hline(img, 10, 12, 3, A); put(img, 11, 3, AH)
    put(img, 9, 3, OUTLINE); put(img, 13, 3, OUTLINE)
    for y in range(4, 7):
        w = y - 2
        hline(img, 11-w, 11+w, y, A)
        put(img, 11-w-1, y, OUTLINE); put(img, 11+w+1, y, OUTLINE)
    # 머리 (넓은 후드)
    for y in range(7, 14):
        put(img, 5, y, OUTLINE); put(img, 17, y, OUTLINE)
        hline(img, 6, 16, y, A)
    hline(img, 5, 17, 14, OUTLINE)
    vline(img, 6, 7, 13, AH)
    vline(img, 16, 7, 13, AS_)
    # 얼굴 (반쪽 그림자)
    rect(img, 8, 9, 14, 13, BONE_BASE)
    rect(img, 12, 9, 14, 13, BONE_SHADOW) # 오른쪽 그림자
    hline(img, 8, 10, 9, BONE_HI)
    # 눈 (날카로운 슬릿)
    put(img, 9, 10, EYE_CORE); put(img, 10, 11, EYE_BRIGHT)
    put(img, 13, 10, EYE_CORE); put(img, 12, 11, EYE_BRIGHT)
    # 날렵한 몸 (좁음!)
    rect(img, 9, 14, 13, 19, A)
    vline(img, 8, 14, 20, OUTLINE); vline(img, 14, 14, 20, OUTLINE)
    vline(img, 9, 14, 19, AH); vline(img, 13, 14, 19, AS_)
    hline(img, 8, 14, 20, OUTLINE)
    # 벨트
    hline(img, 9, 13, 17, AS_)
    put(img, 11, 17, AA)
    # 쌍단검 (크고 눈에 띄게)
    # 왼쪽 단검 (역방향)
    for i in range(5):
        put(img, 5-i, 11+i, METAL_HI)
    put(img, 5, 10, METAL_BASE); put(img, 6, 11, OUTLINE)
    # 오른쪽 단검
    for i in range(5):
        put(img, 17+i, 11+i, METAL_HI)
    put(img, 17, 10, METAL_BASE); put(img, 16, 11, OUTLINE)
    # 독기 파티클
    put(img, 3, 16, AA); put(img, 20, 14, AA); put(img, 2, 12, AA)
    # 다리 (날씬)
    vline(img, 10, 20, 22, AS_); vline(img, 12, 20, 22, AS_)
    put(img, 10, 23, OUTLINE); put(img, 12, 23, OUTLINE)
    return img

def draw_guardian():
    """수호자: 거대 방패 + 중갑 + 넓은 체형."""
    img = create_sprite(24, 24)
    G = GUARDIAN_BASE; GH = GUARDIAN_HI; GS = GUARDIAN_SHADOW; GA = GUARDIAN_ACCENT
    # 무거운 투구 (바이저 내려간)
    hline(img, 8, 15, 4, OUTLINE)
    for y in range(5, 9):
        put(img, 7, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 8, 15, y, METAL_BASE)
    hline(img, 8, 12, 5, METAL_HI); vline(img, 8, 5, 8, METAL_HI)
    hline(img, 12, 15, 8, METAL_SHADOW); vline(img, 15, 5, 8, METAL_SHADOW)
    # 바이저 슬릿 (가로)
    hline(img, 9, 14, 7, METAL_DARK)
    put(img, 10, 7, EYE_BRIGHT); put(img, 13, 7, EYE_BRIGHT) # 눈빛 슬릿
    # 얼굴 하단 (턱 가드)
    for y in range(9, 14):
        put(img, 7, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 8, 15, y, G)
    hline(img, 7, 16, 14, OUTLINE)
    vline(img, 8, 9, 13, GH); vline(img, 15, 9, 13, GS)
    # 거대한 몸 (넓은!)
    for y in range(14, 21):
        w = 6
        hline(img, 11-w, 11+w, y, G)
        put(img, 11-w-1, y, OUTLINE); put(img, 11+w+1, y, OUTLINE)
    hline(img, 4, 18, 21, OUTLINE)
    # 몸 셰이딩
    for y in range(14, 20):
        put(img, 5, y, GH); put(img, 17, y, GS)
    # 벨트
    hline(img, 5, 17, 18, GS)
    put(img, 11, 18, GA)
    # 거대 방패 (왼쪽, 눈에 띄게 큼)
    rect(img, 0, 9, 5, 19, G)
    vline(img, 0, 9, 19, GH); vline(img, 5, 9, 19, GS)
    hline(img, 0, 5, 9, GH); hline(img, 0, 5, 19, GS)
    outline_rect(img, 0, 8, 6, 20, OUTLINE)
    # 방패 장식 (십자)
    vline(img, 3, 11, 17, GA)
    hline(img, 1, 5, 14, GA)
    put(img, 3, 14, EYE_CORE)
    # 다리 (두꺼운)
    rect(img, 7, 21, 10, 23, GS); rect(img, 12, 21, 15, 23, GS)
    hline(img, 7, 10, 23, OUTLINE); hline(img, 12, 15, 23, OUTLINE)
    return img

def draw_wanderer():
    """방랑자: 넓은 모자 + 펄럭이는 망토 + 가벼운 느낌."""
    img = create_sprite(24, 24)
    W = WANDERER_BASE; WH = WANDERER_HI; WS = WANDERER_SHADOW; WA = WANDERER_ACCENT
    # 넓은 모자 (매우 넓어야 방랑자 느낌)
    hline(img, 8, 14, 3, OUTLINE)
    rect(img, 9, 4, 13, 6, W)
    hline(img, 9, 11, 4, WH)
    outline_rect(img, 8, 3, 14, 7, OUTLINE)
    # 매우 넓은 챙
    hline(img, 2, 20, 7, OUTLINE)
    hline(img, 3, 19, 7, W)
    hline(img, 3, 11, 7, WH)
    hline(img, 12, 19, 7, WS)
    hline(img, 2, 20, 8, OUTLINE)
    # 머리
    for y in range(8, 14):
        put(img, 6, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 7, 15, y, W)
    hline(img, 6, 16, 14, OUTLINE)
    vline(img, 7, 8, 13, WH); vline(img, 15, 8, 13, WS)
    # 얼굴
    rect(img, 8, 9, 14, 13, BONE_BASE)
    hline(img, 8, 11, 9, BONE_HI)
    hline(img, 12, 14, 13, BONE_SHADOW)
    # 눈
    put(img, 9, 11, EYE_CORE); put(img, 10, 11, EYE_BRIGHT)
    put(img, 12, 11, EYE_BRIGHT); put(img, 13, 11, EYE_CORE)
    # 슬림한 몸
    rect(img, 9, 14, 13, 19, W)
    vline(img, 8, 14, 20, OUTLINE); vline(img, 14, 14, 20, OUTLINE)
    vline(img, 9, 14, 19, WH); vline(img, 13, 14, 19, WS)
    hline(img, 8, 14, 20, OUTLINE)
    # 펄럭이는 망토 (오른쪽으로 크게 펄럭)
    for i in range(7):
        put(img, 15+i, 13+i, W)
        put(img, 15+i, 14+i, WS)
        put(img, 15+i, 15+i, OUTLINE)
    put(img, 16, 13, WH)
    # 바람 파티클 (방랑자 시그니처)
    put(img, 21, 9, WA); put(img, 22, 11, WA); put(img, 20, 7, WA)
    put(img, 23, 13, WA)
    # 벨트
    hline(img, 9, 13, 17, WS)
    put(img, 11, 17, GOLD_SHADOW)
    # 다리
    vline(img, 10, 20, 22, WS); vline(img, 12, 20, 22, WS)
    put(img, 10, 23, OUTLINE); put(img, 12, 23, OUTLINE)
    return img

def draw_reaper():
    """사신: 뾰족하고 긴 후드 + 거대 낫 + 떠있는 느낌."""
    img = create_sprite(24, 24)
    R = REAPER_BASE; RH = REAPER_HI; RS = REAPER_SHADOW; RA = REAPER_ACCENT
    # 매우 뾰족한 긴 후드
    put(img, 11, 0, OUTLINE)
    put(img, 11, 1, RH)
    put(img, 10, 1, OUTLINE); put(img, 12, 1, OUTLINE)
    put(img, 10, 2, RH); put(img, 11, 2, RH); put(img, 12, 2, RH)
    put(img, 9, 2, OUTLINE); put(img, 13, 2, OUTLINE)
    for y in range(3, 7):
        w = min(y, 5)
        hline(img, 11-w, 11+w, y, R)
        put(img, 11-w-1, y, OUTLINE); put(img, 11+w+1, y, OUTLINE)
    # 머리
    for y in range(7, 14):
        put(img, 5, y, OUTLINE); put(img, 17, y, OUTLINE)
        hline(img, 6, 16, y, R)
    hline(img, 5, 17, 14, OUTLINE)
    vline(img, 6, 7, 13, RH); vline(img, 16, 7, 13, RS)
    # 어두운 얼굴 (거의 안 보임)
    rect(img, 8, 9, 14, 13, (20, 8, 15, 255))
    # 불타는 빨간 눈 (사신의 핵심!)
    put(img, 9, 10, RA); put(img, 10, 10, EYE_CORE); put(img, 10, 11, RA)
    put(img, 13, 10, EYE_CORE); put(img, 14, 10, RA); put(img, 13, 11, RA)
    # 로브 (아래로 넓어지며 떠있는 느낌)
    for y in range(14, 22):
        w = 3 + (y - 14) // 3
        hline(img, 11-w, 11+w, y, R)
        put(img, 11-w-1, y, OUTLINE); put(img, 11+w+1, y, OUTLINE)
    # 로브 하단 (지그재그 = 떠있는 느낌)
    for x in range(6, 17, 2):
        put(img, x, 22, R)
        put(img, x, 23, OUTLINE)
    # 거대 낫 (사신의 시그니처!)
    vline(img, 19, 2, 21, BONE_SHADOW)
    # 낫날 (L자 + 곡선)
    hline(img, 15, 19, 2, METAL_HI)
    hline(img, 14, 18, 3, METAL_BASE)
    put(img, 14, 4, METAL_BASE); put(img, 13, 5, METAL_SHADOW)
    # 낫날 끝 발광
    put(img, 13, 4, RA); put(img, 14, 3, RA)
    return img

def draw_illusionist():
    """환술사: 반가면 + 부유하는 카드들 + 비대칭."""
    img = create_sprite(24, 24)
    I = ILLUSION_BASE; IH = ILLUSION_HI; IS = ILLUSION_SHADOW; IA = ILLUSION_ACCENT
    # 머리 (둥근 + 비대칭 머리장식)
    hline(img, 7, 15, 4, OUTLINE)
    for y in range(5, 8):
        put(img, 6, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 7, 15, y, I)
    hline(img, 7, 11, 5, IH); vline(img, 7, 5, 7, IH)
    hline(img, 11, 15, 7, IS); vline(img, 15, 5, 7, IS)
    # 깃털 장식 (왼쪽에만 = 비대칭)
    put(img, 6, 3, IH); put(img, 5, 2, IA); put(img, 5, 1, OUTLINE)
    put(img, 6, 2, OUTLINE)
    # 머리
    for y in range(8, 14):
        put(img, 5, y, OUTLINE); put(img, 17, y, OUTLINE)
        hline(img, 6, 16, y, I)
    hline(img, 5, 17, 14, OUTLINE)
    vline(img, 6, 8, 13, IH); vline(img, 16, 8, 13, IS)
    # 반가면 (오른쪽만 밝은 가면)
    rect(img, 7, 9, 10, 13, BONE_BASE)
    rect(img, 12, 9, 16, 13, BONE_HI)
    vline(img, 11, 9, 13, I) # 가면 경계
    hline(img, 7, 10, 9, BONE_HI)
    # 눈 (좌: 자연, 우: 가면 슬릿)
    put(img, 8, 11, EYE_CORE); put(img, 9, 11, IA)
    put(img, 14, 11, IH); put(img, 13, 11, IS) # 가면 슬릿
    # 몸통
    rect(img, 8, 14, 14, 20, I)
    vline(img, 7, 14, 21, OUTLINE); vline(img, 15, 14, 21, OUTLINE)
    vline(img, 8, 14, 20, IH); vline(img, 14, 14, 20, IS)
    hline(img, 7, 15, 21, OUTLINE)
    # 벨트
    hline(img, 8, 14, 18, IS)
    put(img, 11, 18, IA)
    # 부유하는 카드/거울 조각 3개 (환술사 시그니처!)
    # 카드1 (오른쪽 위)
    rect(img, 19, 6, 21, 10, IA)
    outline_rect(img, 18, 5, 22, 11, OUTLINE)
    put(img, 20, 8, EYE_CORE)
    # 카드2 (왼쪽)
    rect(img, 1, 10, 3, 14, IA)
    outline_rect(img, 0, 9, 4, 15, OUTLINE)
    put(img, 2, 12, EYE_CORE)
    # 카드3 (오른쪽 아래, 작게)
    rect(img, 19, 15, 20, 18, IA)
    outline_rect(img, 18, 14, 21, 19, OUTLINE)
    # 다리
    vline(img, 9, 21, 22, IS); vline(img, 13, 21, 22, IS)
    put(img, 9, 23, OUTLINE); put(img, 13, 23, OUTLINE)
    return img

def draw_harmonist():
    """조율사: 양 갈래 장식 + 빛나는 오브 + 균형 잡힌 모습."""
    img = create_sprite(24, 24)
    H = HARMONY_BASE; HH = HARMONY_HI; HS = HARMONY_SHADOW; HA = HARMONY_ACCENT
    # 양 갈래 머리장식 (결정/안테나 형태)
    # 왼쪽
    put(img, 7, 1, HA); put(img, 7, 2, HH); put(img, 7, 3, H)
    put(img, 6, 1, OUTLINE); put(img, 8, 1, OUTLINE); put(img, 7, 0, OUTLINE)
    # 오른쪽
    put(img, 15, 1, HA); put(img, 15, 2, HH); put(img, 15, 3, H)
    put(img, 14, 1, OUTLINE); put(img, 16, 1, OUTLINE); put(img, 15, 0, OUTLINE)
    # 머리밴드
    hline(img, 7, 15, 4, OUTLINE)
    hline(img, 8, 14, 4, HA)
    # 머리
    hline(img, 7, 15, 5, OUTLINE)
    for y in range(5, 8):
        put(img, 6, y, OUTLINE); put(img, 16, y, OUTLINE)
        hline(img, 7, 15, y, H)
    hline(img, 7, 11, 5, HH); vline(img, 7, 5, 7, HH)
    hline(img, 11, 15, 7, HS); vline(img, 15, 5, 7, HS)
    # 큰 머리
    for y in range(8, 14):
        put(img, 5, y, OUTLINE); put(img, 17, y, OUTLINE)
        hline(img, 6, 16, y, H)
    hline(img, 5, 17, 14, OUTLINE)
    vline(img, 6, 8, 13, HH); vline(img, 16, 8, 13, HS)
    # 얼굴
    rect(img, 8, 9, 14, 13, BONE_BASE)
    hline(img, 8, 11, 9, BONE_HI)
    hline(img, 12, 14, 13, BONE_SHADOW)
    # 눈 (조화로운 청록빛)
    put(img, 9, 11, EYE_CORE); put(img, 10, 11, HA)
    put(img, 12, 11, HA); put(img, 13, 11, EYE_CORE)
    # 몸통
    rect(img, 8, 14, 14, 20, H)
    vline(img, 7, 14, 21, OUTLINE); vline(img, 15, 14, 21, OUTLINE)
    vline(img, 8, 14, 20, HH); vline(img, 14, 14, 20, HS)
    hline(img, 7, 15, 21, OUTLINE)
    # 벨트
    hline(img, 8, 14, 18, HS)
    put(img, 11, 18, HA)
    # 빛나는 오브 2개 (양손에 = 조율 컨셉)
    # 왼쪽 오브
    filled_circle(img, 3, 14, 2, HA)
    put(img, 3, 13, EYE_CORE); put(img, 2, 14, HH)
    outline_circle(img, 3, 14, 2, OUTLINE)
    # 오른쪽 오브
    filled_circle(img, 19, 14, 2, HA)
    put(img, 19, 13, EYE_CORE); put(img, 20, 14, HH)
    outline_circle(img, 19, 14, 2, OUTLINE)
    # 에너지 연결선 (오브 → 몸)
    put(img, 5, 14, HA); put(img, 6, 14, HA)
    put(img, 16, 14, HA); put(img, 17, 14, HA)
    # 다리
    rect(img, 9, 21, 10, 22, HS); rect(img, 12, 21, 13, 22, HS)
    hline(img, 9, 10, 23, OUTLINE); hline(img, 12, 13, 23, OUTLINE)
    return img

# ============================================================
# MAIN
# ============================================================
if __name__ == '__main__':
    print("=== Part 1: App Icon + 9 Job Icons (v2 Redesign) ===")

    # 앱 아이콘
    icon = draw_app_icon()
    base = 'android/app/src/main/res'
    sizes = {'mipmap-mdpi': 48, 'mipmap-hdpi': 72, 'mipmap-xhdpi': 96,
             'mipmap-xxhdpi': 144, 'mipmap-xxxhdpi': 192}
    for folder, size in sizes.items():
        save_scaled(icon, f'{base}/{folder}/ic_launcher.png', size)
    save_scaled(icon, 'assets/pixel_art/preview/app_icon_preview.png', 512)
    print("  [OK] App icon (5 mipmap + preview)")

    jobs = {
        'warrior': draw_warrior,
        'saint': draw_saint,
        'sage': draw_sage,
        'assassin': draw_assassin,
        'guardian': draw_guardian,
        'wanderer': draw_wanderer,
        'reaper': draw_reaper,
        'illusionist': draw_illusionist,
        'harmonist': draw_harmonist,
    }
    for name, fn in jobs.items():
        img = fn()
        save_asset(img, f'assets/pixel_art/jobs/{name}.png')
        print(f"  [OK] Job: {name}")

    print(f"Part 1 complete: 1 app icon + {len(jobs)} job icons")
