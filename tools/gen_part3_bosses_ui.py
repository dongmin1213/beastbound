"""Part 3: 보스 초상화 5종 + 선택 에셋 (UI/카드/타이틀/배경) — v2 대폭 개선."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from pixel_common import *


# ============================================================
# Helper: draw a line between two arbitrary points (Bresenham)
# ============================================================
def line(img, x0, y0, x1, y1, color):
    """Bresenham line for web lines, wing edges, etc."""
    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy
    while True:
        put(img, x0, y0, color)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy


# ============================================================
# 보스 초상화 (48x48) — 5종  (v2: 대폭 디테일 추가)
# ============================================================

def draw_slime_king():
    """1층 보스: 슬라임 왕 — 거대 슬라임 + 왕관 + 내부 해골 + 미니 슬라임."""
    img = create_sprite(48, 48)

    # --- 색상 ---
    S_HI  = (130, 155, 90, 255)
    S_BASE = FLOOR1_BASE              # (90, 100, 70)
    S_MID  = (75, 85, 60, 255)
    S_SH   = (55, 65, 42, 255)
    S_DARK = (40, 48, 30, 255)

    # --- 미니 슬라임 (왼쪽 아래) ---
    filled_circle(img, 8, 40, 4, S_BASE)
    filled_circle(img, 7, 39, 2, S_HI)
    outline_circle(img, 8, 40, 4, OUTLINE)
    put(img, 7, 39, EYE_RED)
    put(img, 9, 39, EYE_RED)

    # --- 미니 슬라임 (오른쪽 아래) ---
    filled_circle(img, 40, 42, 3, S_MID)
    filled_circle(img, 39, 41, 2, S_BASE)
    outline_circle(img, 40, 42, 3, OUTLINE)
    put(img, 39, 41, EYE_RED)
    put(img, 41, 41, EYE_RED)

    # --- 미니 슬라임 (왼쪽 위 작은) ---
    filled_circle(img, 5, 30, 2, S_MID)
    outline_circle(img, 5, 30, 2, OUTLINE)
    put(img, 5, 29, EYE_RED)

    # --- 본체: 거대 슬라임 blob ---
    # 메인 몸체 (큰 원)
    filled_circle(img, 24, 28, 17, S_BASE)
    # 상단 밝은 영역 (광원 좌상단)
    filled_circle(img, 20, 23, 12, S_HI)
    # 중간 톤
    filled_circle(img, 22, 26, 10, S_BASE)
    # 하단 그림자
    filled_circle(img, 26, 33, 10, S_MID)
    filled_circle(img, 28, 36, 7, S_SH)

    # 슬라임 표면 하이라이트 반점
    put(img, 14, 18, (160, 190, 110, 255))
    put(img, 15, 18, (160, 190, 110, 255))
    put(img, 13, 19, (160, 190, 110, 255))

    # 아웃라인
    outline_circle(img, 24, 28, 17, OUTLINE)

    # 슬라임 바닥 퍼짐 (좌우로 약간 넓게)
    for x in range(10, 39):
        if img.getpixel((x, 44)) == TRANSPARENT:
            put(img, x, 44, S_SH)
        if img.getpixel((x, 45)) == TRANSPARENT:
            put(img, x, 45, S_DARK)
    hline(img, 9, 39, 46, OUTLINE)

    # --- 내부 해골 1 (왼쪽 하단 안쪽) ---
    # 해골 두개골
    rect(img, 15, 30, 19, 33, BONE_SHADOW)
    put(img, 16, 30, BONE_BASE)
    put(img, 17, 30, BONE_BASE)
    put(img, 18, 30, BONE_BASE)
    put(img, 16, 31, BONE_HI)
    put(img, 18, 31, BONE_HI)
    # 눈구멍
    put(img, 16, 31, OUTLINE)
    put(img, 18, 31, OUTLINE)
    # 이빨
    put(img, 16, 33, BONE_HI)
    put(img, 18, 33, BONE_HI)

    # --- 내부 해골 2 (오른쪽 하단) ---
    rect(img, 27, 33, 31, 36, BONE_SHADOW)
    put(img, 28, 33, BONE_BASE)
    put(img, 29, 33, BONE_BASE)
    put(img, 30, 33, BONE_BASE)
    put(img, 28, 34, BONE_HI)
    put(img, 30, 34, BONE_HI)
    put(img, 28, 34, OUTLINE)
    put(img, 30, 34, OUTLINE)
    put(img, 28, 36, BONE_HI)
    put(img, 30, 36, BONE_HI)

    # --- 내부 해골 3 (중앙 위 - 반쯤 녹음) ---
    put(img, 22, 35, BONE_SHADOW)
    put(img, 23, 35, BONE_SHADOW)
    put(img, 22, 36, OUTLINE)
    put(img, 23, 36, BONE_SHADOW)

    # --- 눈 (크고 사악한) ---
    # 왼쪽 눈 (4x3)
    rect(img, 16, 21, 20, 24, OUTLINE)
    rect(img, 17, 22, 19, 23, EYE_RED)
    put(img, 17, 22, EYE_CORE)
    put(img, 19, 23, (180, 40, 40, 255))

    # 오른쪽 눈 (4x3)
    rect(img, 26, 21, 30, 24, OUTLINE)
    rect(img, 27, 22, 29, 23, EYE_RED)
    put(img, 29, 22, EYE_CORE)
    put(img, 27, 23, (180, 40, 40, 255))

    # --- 입 (넓은 사악한 미소) ---
    hline(img, 18, 28, 27, OUTLINE)
    hline(img, 17, 29, 28, OUTLINE)
    # 내부 어두운 입
    hline(img, 19, 27, 28, S_DARK)
    # 이빨
    for x in [19, 21, 23, 25, 27]:
        put(img, x, 27, BONE_HI)

    # --- 왕관 (큰, 화려한) ---
    # 왕관 밴드
    hline(img, 14, 34, 13, GOLD_SHADOW)
    hline(img, 14, 34, 12, GOLD_BASE)
    hline(img, 14, 34, 11, GOLD_HI)
    # 왕관 뾰족 장식 5개
    crown_peaks = [16, 20, 24, 28, 32]
    for cx in crown_peaks:
        put(img, cx, 10, GOLD_HI)
        put(img, cx, 9, GOLD_HI)
        put(img, cx - 1, 10, GOLD_BASE)
        put(img, cx + 1, 10, GOLD_BASE)
        put(img, cx, 8, OUTLINE)
        put(img, cx - 1, 9, OUTLINE)
        put(img, cx + 1, 9, OUTLINE)
    # 왕관 보석
    put(img, 24, 10, EYE_RED)       # 중앙 루비
    put(img, 20, 10, SOUL_BRIGHT)   # 좌 보석
    put(img, 28, 10, SOUL_BRIGHT)   # 우 보석

    # 왕관 아웃라인 하단
    hline(img, 13, 35, 14, OUTLINE)
    put(img, 13, 11, OUTLINE)
    put(img, 13, 12, OUTLINE)
    put(img, 13, 13, OUTLINE)
    put(img, 35, 11, OUTLINE)
    put(img, 35, 12, OUTLINE)
    put(img, 35, 13, OUTLINE)

    return img


def draw_spider_lord():
    """2층 보스: 거미 군주 — 거대 거미 + 8다리 + 거미줄 + 알주머니."""
    img = create_sprite(48, 48)

    SP_HI   = (110, 95, 130, 255)
    SP_BASE = (75, 65, 95, 255)
    SP_MID  = (55, 45, 75, 255)
    SP_SH   = (40, 32, 58, 255)
    SP_DARK = (25, 18, 38, 255)
    WEB     = (90, 85, 100, 120)   # 거미줄 (약간 투명 - glow 예외)
    WEB_S   = (60, 55, 75, 255)    # 불투명 거미줄

    # --- 거미줄 배경 (선으로만, 투명 영역에 그리드 채우지 않음!) ---
    # 방사형 거미줄 - 중심(24,20)에서 뻗어나감
    web_cx, web_cy = 24, 18
    web_ends = [(0, 0), (12, 0), (24, 0), (36, 0), (47, 0),
                (0, 15), (47, 15),
                (0, 30), (47, 30),
                (0, 47), (12, 47), (36, 47), (47, 47)]
    for ex, ey in web_ends:
        line(img, web_cx, web_cy, ex, ey, WEB_S)

    # 동심원 거미줄 (부분적)
    for r in [8, 14, 20]:
        for angle_step in range(16):
            import math
            a = angle_step * math.pi * 2 / 16
            x1 = int(web_cx + r * math.cos(a))
            y1 = int(web_cy + r * math.sin(a))
            a2 = (angle_step + 1) * math.pi * 2 / 16
            x2 = int(web_cx + r * math.cos(a2))
            y2 = int(web_cy + r * math.sin(a2))
            line(img, x1, y1, x2, y2, WEB_S)

    # --- 거대 머리 (두부) ---
    filled_circle(img, 24, 14, 11, SP_BASE)
    filled_circle(img, 21, 11, 7, SP_HI)      # 좌상 하이라이트
    filled_circle(img, 27, 17, 6, SP_SH)      # 우하 그림자
    outline_circle(img, 24, 14, 11, OUTLINE)

    # 머리 무늬 (십자 모양 어두운 줄)
    vline(img, 24, 6, 22, SP_MID)
    hline(img, 17, 31, 14, SP_MID)

    # --- 금빛 눈 6개 (2열) ---
    # 상단 대형 2개
    rect(img, 18, 10, 20, 12, OUTLINE)
    put(img, 19, 11, EYE_GOLD)
    put(img, 18, 11, EYE_CORE)

    rect(img, 27, 10, 29, 12, OUTLINE)
    put(img, 28, 11, EYE_GOLD)
    put(img, 29, 11, EYE_CORE)

    # 중단 중형 2개
    put(img, 21, 14, OUTLINE)
    put(img, 22, 13, OUTLINE)
    put(img, 22, 14, EYE_GOLD)
    put(img, 21, 13, EYE_CORE)

    put(img, 26, 14, OUTLINE)
    put(img, 25, 13, OUTLINE)
    put(img, 25, 14, EYE_GOLD)
    put(img, 26, 13, EYE_CORE)

    # 하단 소형 2개
    put(img, 22, 17, EYE_GOLD)
    put(img, 26, 17, EYE_GOLD)

    # --- 이빨 (첼리세라) ---
    put(img, 21, 23, BONE_HI)
    put(img, 22, 24, BONE_HI)
    put(img, 22, 25, BONE_BASE)
    put(img, 27, 23, BONE_HI)
    put(img, 26, 24, BONE_HI)
    put(img, 26, 25, BONE_BASE)
    # 독 방울
    put(img, 22, 26, (0, 200, 80, 255))
    put(img, 26, 26, (0, 200, 80, 255))

    # --- 거대 몸통 (복부) ---
    filled_circle(img, 24, 34, 12, SP_BASE)
    filled_circle(img, 21, 31, 8, SP_HI)
    filled_circle(img, 27, 37, 7, SP_SH)
    outline_circle(img, 24, 34, 12, OUTLINE)

    # 복부 무늬 (해골 모양)
    put(img, 22, 31, SP_DARK)
    put(img, 26, 31, SP_DARK)
    hline(img, 22, 26, 33, SP_DARK)
    put(img, 23, 34, SP_DARK)
    put(img, 25, 34, SP_DARK)

    # --- 다리 8개 (4쌍, 관절 있는 긴 다리) ---
    leg_origins = [
        # (body_x, body_y, knee_x, knee_y, foot_x, foot_y)
        # 좌 상 1
        (15, 12, 6, 8, 1, 14),
        # 좌 2
        (14, 16, 4, 18, 0, 26),
        # 좌 3
        (14, 28, 5, 32, 1, 40),
        # 좌 하 4
        (16, 34, 8, 40, 4, 46),
        # 우 상 1
        (33, 12, 42, 8, 47, 14),
        # 우 2
        (34, 16, 44, 18, 47, 26),
        # 우 3
        (34, 28, 43, 32, 47, 40),
        # 우 하 4
        (32, 34, 40, 40, 44, 46),
    ]
    for bx, by, kx, ky, fx, fy in leg_origins:
        # 상완
        line(img, bx, by, kx, ky, SP_SH)
        # 보강 (두께 +1)
        line(img, bx, by + 1, kx, ky + 1, SP_DARK)
        # 하완
        line(img, kx, ky, fx, fy, SP_MID)
        line(img, kx, ky + 1, fx, fy + 1, SP_DARK)
        # 관절 점
        put(img, kx, ky, SP_HI)
        # 발끝
        put(img, fx, fy, OUTLINE)

    # --- 알주머니 (하단 중앙) ---
    filled_circle(img, 24, 44, 4, BONE_BASE)
    filled_circle(img, 23, 43, 2, BONE_HI)
    outline_circle(img, 24, 44, 4, OUTLINE)
    # 알 내부 점
    put(img, 23, 43, (220, 210, 180, 255))
    put(img, 25, 44, (200, 190, 160, 255))
    put(img, 24, 45, (190, 175, 150, 255))

    return img


def draw_orc_general():
    """3층 보스: 오크 대장군 — 전쟁 갑옷 + 거대 도끼 + 뿔 투구."""
    img = create_sprite(48, 48)

    ORC_HI   = (120, 175, 90, 255)
    ORC_BASE = (85, 140, 65, 255)
    ORC_SH   = (60, 100, 45, 255)
    ORC_DARK = (40, 70, 30, 255)
    SKIN_SCAR = (150, 80, 50, 255)  # 상처

    # --- 전쟁 투구 ---
    # 투구 본체
    rect(img, 12, 3, 35, 10, METAL_BASE)
    # 셰이딩
    hline(img, 13, 24, 4, METAL_HI)
    hline(img, 13, 24, 5, METAL_HI)
    vline(img, 12, 4, 9, METAL_HI)
    hline(img, 25, 34, 9, METAL_SHADOW)
    hline(img, 25, 34, 10, METAL_SHADOW)
    vline(img, 35, 4, 9, METAL_SHADOW)
    # 투구 중앙 능선
    vline(img, 23, 3, 10, METAL_HI)
    vline(img, 24, 3, 10, METAL_HI)
    # 투구 아웃라인
    outline_rect(img, 11, 2, 36, 11, OUTLINE)
    # 코 가드
    vline(img, 23, 11, 14, METAL_BASE)
    vline(img, 24, 11, 14, METAL_SHADOW)
    put(img, 23, 15, OUTLINE)
    put(img, 24, 15, OUTLINE)

    # --- 투구 뿔 (크고 위압적) ---
    # 왼쪽 뿔
    for i in range(6):
        put(img, 10 - i, 4 - i, BONE_BASE)
        put(img, 10 - i, 5 - i, BONE_SHADOW)
        if i < 5:
            put(img, 9 - i, 4 - i, OUTLINE)
            put(img, 10 - i, 6 - i, OUTLINE)
    put(img, 4, -2 + 1, OUTLINE)  # tip
    # 오른쪽 뿔
    for i in range(6):
        put(img, 37 + i, 4 - i, BONE_BASE)
        put(img, 37 + i, 5 - i, BONE_SHADOW)
        if i < 5:
            put(img, 38 + i, 4 - i, OUTLINE)
            put(img, 37 + i, 6 - i, OUTLINE)
    put(img, 43, -2 + 1, OUTLINE)

    # --- 얼굴 (투구 아래 보이는 부분) ---
    rect(img, 13, 11, 34, 19, ORC_BASE)
    # 셰이딩
    hline(img, 14, 22, 11, ORC_HI)
    vline(img, 13, 11, 18, ORC_HI)
    hline(img, 23, 33, 18, ORC_SH)
    vline(img, 34, 11, 18, ORC_SH)
    outline_rect(img, 12, 11, 35, 20, OUTLINE)

    # 상처 (왼쪽 뺨)
    line(img, 14, 13, 17, 17, SKIN_SCAR)

    # --- 눈 (금빛, 위협적, 투구 슬릿 아래) ---
    # 왼쪽 눈
    rect(img, 16, 13, 20, 15, OUTLINE)
    put(img, 17, 14, EYE_GOLD)
    put(img, 18, 14, EYE_CORE)
    put(img, 19, 14, EYE_GOLD)

    # 오른쪽 눈
    rect(img, 27, 13, 31, 15, OUTLINE)
    put(img, 28, 14, EYE_GOLD)
    put(img, 29, 14, EYE_CORE)
    put(img, 30, 14, EYE_GOLD)

    # --- 아래턱 (큰 이빨) ---
    rect(img, 16, 17, 31, 20, ORC_DARK)
    # 이빨 (위)
    for x in [17, 20, 23, 26, 29]:
        put(img, x, 16, BONE_HI)
        put(img, x, 17, BONE_BASE)
    # 큰 엄니 (양 옆)
    put(img, 15, 17, BONE_HI)
    put(img, 15, 18, BONE_HI)
    put(img, 15, 19, BONE_BASE)
    put(img, 14, 18, OUTLINE)
    put(img, 14, 19, OUTLINE)
    put(img, 15, 20, OUTLINE)

    put(img, 32, 17, BONE_HI)
    put(img, 32, 18, BONE_HI)
    put(img, 32, 19, BONE_BASE)
    put(img, 33, 18, OUTLINE)
    put(img, 33, 19, OUTLINE)
    put(img, 32, 20, OUTLINE)

    # --- 어깨 장갑 (넓고 무거운) ---
    # 왼쪽 어깨
    rect(img, 4, 20, 15, 27, METAL_BASE)
    hline(img, 5, 12, 21, METAL_HI)
    vline(img, 4, 21, 26, METAL_HI)
    hline(img, 8, 14, 26, METAL_SHADOW)
    vline(img, 15, 21, 26, METAL_SHADOW)
    outline_rect(img, 3, 19, 16, 28, OUTLINE)
    # 어깨 장식 (금)
    put(img, 9, 22, GOLD_HI)
    put(img, 10, 22, GOLD_BASE)
    put(img, 9, 23, GOLD_BASE)
    put(img, 10, 23, GOLD_SHADOW)

    # 오른쪽 어깨
    rect(img, 32, 20, 43, 27, METAL_BASE)
    hline(img, 33, 40, 21, METAL_HI)
    vline(img, 32, 21, 26, METAL_HI)
    hline(img, 36, 42, 26, METAL_SHADOW)
    vline(img, 43, 21, 26, METAL_SHADOW)
    outline_rect(img, 31, 19, 44, 28, OUTLINE)
    put(img, 37, 22, GOLD_HI)
    put(img, 38, 22, GOLD_BASE)

    # --- 흉갑 (전쟁 갑옷) ---
    rect(img, 12, 21, 35, 36, METAL_BASE)
    # 셰이딩
    hline(img, 13, 24, 22, METAL_HI)
    vline(img, 12, 22, 35, METAL_HI)
    hline(img, 25, 34, 35, METAL_SHADOW)
    vline(img, 35, 22, 35, METAL_SHADOW)
    outline_rect(img, 11, 20, 36, 37, OUTLINE)

    # 흉갑 중앙 장식
    vline(img, 23, 23, 35, METAL_HI)
    vline(img, 24, 23, 35, METAL_HI)

    # 벨트
    hline(img, 13, 34, 31, GOLD_SHADOW)
    hline(img, 13, 34, 32, GOLD_BASE)
    hline(img, 13, 34, 33, GOLD_SHADOW)
    # 벨트 버클
    rect(img, 21, 31, 26, 33, GOLD_HI)
    outline_rect(img, 21, 31, 26, 33, GOLD_DARK)

    # --- 대형 전투 도끼 (오른쪽) ---
    # 도끼 자루
    vline(img, 44, 4, 42, BONE_SHADOW)
    vline(img, 45, 4, 42, BONE_DARK)
    # 도끼 머리 (상단, 크고 날카로운)
    rect(img, 43, 3, 47, 16, METAL_BASE)
    # 날 부분 (곡선 표현)
    for i in range(7):
        put(img, 42, 5 + i, METAL_HI)
        put(img, 41, 6 + i, METAL_HI)
    # 도끼 셰이딩
    vline(img, 47, 4, 15, METAL_SHADOW)
    hline(img, 43, 47, 3, METAL_HI)
    hline(img, 43, 47, 16, METAL_SHADOW)
    # 아웃라인
    outline_rect(img, 40, 2, 47, 17, OUTLINE)
    vline(img, 43, 3, 42, OUTLINE)
    vline(img, 46, 17, 42, OUTLINE)
    hline(img, 43, 46, 43, OUTLINE)
    # 도끼 날 아웃라인
    for i in range(7):
        put(img, 40, 5 + i, OUTLINE)

    # --- 다리 (무거운 갑옷 부츠) ---
    # 왼쪽 다리
    rect(img, 14, 37, 21, 43, ORC_SH)
    rect(img, 13, 41, 22, 44, METAL_SHADOW)
    hline(img, 14, 21, 41, METAL_BASE)
    outline_rect(img, 13, 37, 22, 45, OUTLINE)

    # 오른쪽 다리
    rect(img, 26, 37, 33, 43, ORC_SH)
    rect(img, 25, 41, 34, 44, METAL_SHADOW)
    hline(img, 26, 33, 41, METAL_BASE)
    outline_rect(img, 25, 37, 34, 45, OUTLINE)

    return img


def draw_vampire_lord():
    """4층 보스: 뱀파이어 군주 — 귀족풍, 망토, 박쥐 날개, 송곳니."""
    img = create_sprite(48, 48)

    VAMP_HI   = (110, 40, 55, 255)
    VAMP_BASE = (70, 22, 35, 255)
    VAMP_SH   = (45, 12, 22, 255)
    VAMP_DARK = (28, 8, 15, 255)
    SKIN_HI   = (240, 225, 220, 255)  # 창백한 피부 하이라이트
    SKIN_BASE = (210, 195, 190, 255)  # 창백한 피부
    SKIN_SH   = (170, 155, 150, 255)  # 피부 그림자
    HAIR      = (35, 18, 30, 255)
    HAIR_HI   = (55, 30, 48, 255)
    CAPE_IN   = (90, 20, 30, 255)     # 망토 안감 (핏빛)

    # --- 박쥐 날개 (뒤에 먼저 그림) ---
    # 왼쪽 날개
    wing_l = [
        # (x, y) 날개 형태
        (6, 14), (5, 15), (4, 16), (3, 17), (2, 18), (1, 19), (0, 20),
        (5, 16), (4, 17), (3, 18), (2, 19), (1, 20),
        (6, 17), (5, 18), (4, 19), (3, 20), (2, 21),
        (7, 18), (6, 19), (5, 20), (4, 21), (3, 22),
        (7, 20), (6, 21), (5, 22), (4, 23),
        (8, 22), (7, 23), (6, 24), (5, 25),
    ]
    for wx, wy in wing_l:
        put(img, wx, wy, VAMP_SH)

    # 날개 뼈대
    line(img, 8, 16, 0, 20, VAMP_DARK)
    line(img, 8, 18, 2, 22, VAMP_DARK)
    line(img, 8, 20, 4, 26, VAMP_DARK)

    # 날개 끝 갈래
    put(img, 0, 19, OUTLINE)
    put(img, 0, 21, OUTLINE)
    put(img, 1, 22, OUTLINE)
    put(img, 2, 23, OUTLINE)
    put(img, 3, 24, OUTLINE)
    put(img, 4, 25, OUTLINE)
    put(img, 5, 26, OUTLINE)

    # 오른쪽 날개 (대칭)
    for wx, wy in wing_l:
        put(img, 47 - wx, wy, VAMP_SH)
    line(img, 39, 16, 47, 20, VAMP_DARK)
    line(img, 39, 18, 45, 22, VAMP_DARK)
    line(img, 39, 20, 43, 26, VAMP_DARK)
    put(img, 47, 19, OUTLINE)
    put(img, 47, 21, OUTLINE)
    put(img, 46, 22, OUTLINE)
    put(img, 45, 23, OUTLINE)
    put(img, 44, 24, OUTLINE)
    put(img, 43, 25, OUTLINE)
    put(img, 42, 26, OUTLINE)

    # --- 높은 깃 망토 (몸통) ---
    # 망토 외부
    # 좌우 곡선형 - 어깨에서 넓어지다 하단으로
    for y in range(18, 44):
        spread = min((y - 18) // 2, 6)
        lx = 8 - spread
        rx = 39 + spread
        hline(img, lx, rx, y, VAMP_BASE)

    # 망토 셰이딩
    for y in range(19, 43):
        spread = min((y - 18) // 2, 6)
        lx = 8 - spread
        rx = 39 + spread
        put(img, lx, y, VAMP_HI)        # 좌 하이라이트
        put(img, lx + 1, y, VAMP_HI)
        put(img, rx, y, VAMP_SH)         # 우 그림자
        put(img, rx - 1, y, VAMP_SH)

    # 망토 하단 그림자
    for y in range(40, 44):
        spread = min((y - 18) // 2, 6)
        lx = 8 - spread
        rx = 39 + spread
        hline(img, lx, rx, y, VAMP_SH)

    # 망토 아웃라인
    for y in range(18, 44):
        spread = min((y - 18) // 2, 6)
        lx = 8 - spread
        rx = 39 + spread
        put(img, lx - 1, y, OUTLINE)
        put(img, rx + 1, y, OUTLINE)
    hline(img, 1, 46, 44, OUTLINE)

    # --- 높은 깃 (목 주변, 뱀파이어 시그니처) ---
    # 왼쪽 깃
    for y in range(12, 22):
        put(img, 10 - (22 - y) // 3, y, VAMP_DARK)
        put(img, 11 - (22 - y) // 3, y, VAMP_HI)
    # 오른쪽 깃
    for y in range(12, 22):
        put(img, 37 + (22 - y) // 3, y, VAMP_DARK)
        put(img, 36 + (22 - y) // 3, y, VAMP_HI)

    # 깃 아웃라인
    for y in range(12, 22):
        put(img, 9 - (22 - y) // 3, y, OUTLINE)
        put(img, 38 + (22 - y) // 3, y, OUTLINE)

    # --- 망토 안감 (핏빛 적색) ---
    rect(img, 14, 24, 33, 40, CAPE_IN)
    rect(img, 15, 25, 32, 32, (110, 30, 40, 255))

    # --- 셔츠/조끼 ---
    rect(img, 17, 22, 30, 34, BONE_SHADOW)
    vline(img, 23, 22, 34, BONE_BASE)  # 셔츠 중앙선
    vline(img, 24, 22, 34, BONE_BASE)
    # V넥
    line(img, 20, 22, 23, 26, BONE_DARK)
    line(img, 27, 22, 24, 26, BONE_DARK)
    # 브로치 (금 + 루비)
    put(img, 23, 23, GOLD_HI)
    put(img, 24, 23, GOLD_HI)
    put(img, 23, 24, GOLD_BASE)
    put(img, 24, 24, EYE_RED)

    # --- 머리 (귀족풍, 창백한 피부) ---
    # 머리 형태 (약간 좁고 긴)
    rect(img, 16, 6, 31, 20, SKIN_BASE)
    # 셰이딩
    hline(img, 17, 24, 7, SKIN_HI)
    vline(img, 16, 7, 19, SKIN_HI)
    hline(img, 25, 30, 19, SKIN_SH)
    vline(img, 31, 7, 19, SKIN_SH)
    outline_rect(img, 15, 5, 32, 21, OUTLINE)

    # --- 머리카락 (뒤로 넘긴 검은 머리) ---
    rect(img, 16, 4, 31, 8, HAIR)
    hline(img, 17, 24, 5, HAIR_HI)
    # 옆머리
    vline(img, 16, 5, 12, HAIR)
    vline(img, 31, 5, 12, HAIR)
    put(img, 15, 6, HAIR)
    put(img, 15, 7, HAIR)
    put(img, 32, 6, HAIR)
    put(img, 32, 7, HAIR)
    outline_rect(img, 14, 3, 33, 9, OUTLINE)
    # 뾰족한 위도우 피크
    put(img, 23, 8, HAIR)
    put(img, 24, 8, HAIR)
    put(img, 23, 9, HAIR)
    put(img, 24, 9, HAIR)

    # --- 눈 (핏빛, 빛나는) ---
    # 왼쪽 눈
    rect(img, 18, 12, 22, 15, OUTLINE)
    put(img, 19, 13, EYE_RED)
    put(img, 20, 13, EYE_CORE)
    put(img, 21, 13, EYE_RED)
    put(img, 19, 14, (180, 40, 40, 255))
    put(img, 20, 14, EYE_RED)
    put(img, 21, 14, (180, 40, 40, 255))

    # 오른쪽 눈
    rect(img, 25, 12, 29, 15, OUTLINE)
    put(img, 26, 13, EYE_RED)
    put(img, 27, 13, EYE_CORE)
    put(img, 28, 13, EYE_RED)
    put(img, 26, 14, (180, 40, 40, 255))
    put(img, 27, 14, EYE_RED)
    put(img, 28, 14, (180, 40, 40, 255))

    # 눈썹 (위협적, 각진)
    line(img, 18, 11, 22, 11, OUTLINE)
    line(img, 25, 11, 29, 11, OUTLINE)
    put(img, 17, 11, OUTLINE)
    put(img, 30, 11, OUTLINE)

    # --- 코 ---
    put(img, 23, 16, SKIN_SH)
    put(img, 24, 16, SKIN_SH)

    # --- 입 + 송곳니 ---
    hline(img, 20, 27, 18, OUTLINE)
    # 송곳니 (뚜렷한)
    put(img, 20, 19, BONE_HI)
    put(img, 20, 20, BONE_HI)
    put(img, 20, 21, BONE_BASE)
    put(img, 19, 20, OUTLINE)
    put(img, 19, 21, OUTLINE)
    put(img, 20, 22, OUTLINE)

    put(img, 27, 19, BONE_HI)
    put(img, 27, 20, BONE_HI)
    put(img, 27, 21, BONE_BASE)
    put(img, 28, 20, OUTLINE)
    put(img, 28, 21, OUTLINE)
    put(img, 27, 22, OUTLINE)

    # 피 한 방울 (왼쪽 송곳니)
    put(img, 20, 22, EYE_RED)

    # --- 손 (망토에서 삐져나옴) ---
    # 왼손
    rect(img, 9, 34, 12, 38, SKIN_SH)
    put(img, 10, 35, SKIN_BASE)
    outline_rect(img, 8, 33, 13, 39, OUTLINE)

    # 오른손
    rect(img, 35, 34, 38, 38, SKIN_SH)
    put(img, 36, 35, SKIN_BASE)
    outline_rect(img, 34, 33, 39, 39, OUTLINE)

    # --- 다리 (망토 아래 살짝) ---
    rect(img, 17, 42, 22, 46, VAMP_DARK)
    rect(img, 26, 42, 31, 46, VAMP_DARK)
    # 부츠
    hline(img, 16, 23, 47, OUTLINE)
    hline(img, 25, 32, 47, OUTLINE)

    return img


def draw_dungeon_master():
    """5층 보스: 던전 마스터 — 왕좌 위 해골 + 소울 코어 + 6팔 + 왕관."""
    img = create_sprite(48, 48)

    DM_HI   = (65, 38, 90, 255)
    DM_BASE = FLOOR5_BASE              # (40, 20, 60)
    DM_SH   = (28, 14, 42, 255)
    DM_DARK = (18, 8, 28, 255)
    THRONE  = (35, 25, 50, 255)
    THRONE_HI = (50, 38, 68, 255)
    THRONE_SH = (22, 14, 35, 255)

    # --- 왕좌 (배경, 큰) ---
    # 등받이 (높고 위엄)
    rect(img, 8, 0, 39, 8, THRONE)
    hline(img, 9, 24, 1, THRONE_HI)
    hline(img, 25, 38, 7, THRONE_SH)
    outline_rect(img, 7, 0, 40, 9, OUTLINE)

    # 등받이 장식 (뾰족한 상단 3개)
    for cx in [16, 23, 30]:
        put(img, cx, 0, THRONE_HI)
        put(img, cx - 1, 0, OUTLINE)
        put(img, cx + 1, 0, OUTLINE)

    # 왕좌 등받이에 소울 문양
    put(img, 23, 3, SOUL_BRIGHT)
    put(img, 24, 3, SOUL_BRIGHT)
    put(img, 23, 4, SOUL_MID)
    put(img, 24, 4, SOUL_MID)

    # 왕좌 본체 (하단)
    rect(img, 6, 8, 41, 44, THRONE_SH)
    # 팔걸이
    rect(img, 3, 22, 8, 42, THRONE)
    hline(img, 4, 7, 23, THRONE_HI)
    vline(img, 3, 23, 41, THRONE_HI)
    hline(img, 5, 7, 41, THRONE_SH)
    outline_rect(img, 2, 21, 9, 43, OUTLINE)

    rect(img, 39, 22, 44, 42, THRONE)
    hline(img, 40, 43, 23, THRONE_HI)
    vline(img, 39, 23, 41, THRONE_HI)
    hline(img, 40, 43, 41, THRONE_SH)
    outline_rect(img, 38, 21, 45, 43, OUTLINE)

    # 팔걸이 장식 (해골)
    put(img, 5, 22, BONE_HI)
    put(img, 6, 22, BONE_HI)
    put(img, 5, 23, BONE_BASE)
    put(img, 6, 23, BONE_BASE)
    put(img, 41, 22, BONE_HI)
    put(img, 42, 22, BONE_HI)
    put(img, 41, 23, BONE_BASE)
    put(img, 42, 23, BONE_BASE)

    # --- 로브 (어둡고 위엄 있는) ---
    rect(img, 12, 22, 35, 40, DM_BASE)
    # 셰이딩
    vline(img, 12, 23, 39, DM_HI)
    vline(img, 13, 23, 39, DM_HI)
    vline(img, 35, 23, 39, DM_SH)
    vline(img, 34, 23, 39, DM_SH)
    hline(img, 14, 33, 39, DM_SH)
    hline(img, 14, 33, 40, DM_DARK)
    outline_rect(img, 11, 21, 36, 41, OUTLINE)

    # 로브 문양 (소울 룬)
    for y in [26, 30, 34, 38]:
        put(img, 23, y, SOUL_FAINT)
        put(img, 24, y, SOUL_FAINT)

    # --- 소울 코어 (가슴, 크고 밝게) ---
    filled_circle(img, 23, 29, 4, SOUL_MID)
    filled_circle(img, 23, 29, 3, SOUL_BRIGHT)
    filled_circle(img, 23, 29, 1, SOUL_WHITE)
    outline_circle(img, 23, 29, 4, OUTLINE)

    # 소울 코어 광선 (4방향)
    for d in range(5, 8):
        put(img, 23, 29 - d, SOUL_FAINT)  # 상
        put(img, 23, 29 + d, SOUL_FAINT)  # 하
        put(img, 23 - d, 29, SOUL_FAINT)  # 좌
        put(img, 23 + d, 29, SOUL_FAINT)  # 우

    # --- 머리 (해골, 크고 위엄) ---
    rect(img, 15, 7, 32, 20, BONE_BASE)
    # 셰이딩
    hline(img, 16, 24, 8, BONE_HI)
    hline(img, 16, 24, 9, BONE_HI)
    vline(img, 15, 8, 19, BONE_HI)
    hline(img, 25, 31, 19, BONE_SHADOW)
    vline(img, 32, 8, 19, BONE_SHADOW)
    hline(img, 25, 31, 18, BONE_SHADOW)
    outline_rect(img, 14, 6, 33, 21, OUTLINE)

    # 이마 주름 (해골)
    hline(img, 17, 30, 10, BONE_SHADOW)

    # 광대뼈
    put(img, 16, 16, BONE_HI)
    put(img, 17, 16, BONE_HI)
    put(img, 30, 16, BONE_HI)
    put(img, 31, 16, BONE_HI)

    # --- 왕관 (소울 보석 장식) ---
    hline(img, 16, 31, 7, GOLD_BASE)
    hline(img, 16, 31, 6, GOLD_HI)
    hline(img, 16, 31, 5, GOLD_HI)
    # 왕관 뾰족 5개
    for cx in [18, 21, 24, 27, 30]:
        put(img, cx, 4, GOLD_HI)
        put(img, cx, 3, GOLD_HI)
        put(img, cx - 1, 4, GOLD_BASE)
        put(img, cx + 1, 4, GOLD_BASE)
        put(img, cx, 2, OUTLINE)
        put(img, cx - 1, 3, OUTLINE)
        put(img, cx + 1, 3, OUTLINE)
    # 소울 보석 (왕관 중앙)
    put(img, 24, 4, SOUL_WHITE)
    put(img, 24, 5, SOUL_BRIGHT)
    # 왕관 아웃라인
    hline(img, 15, 32, 8, OUTLINE)
    put(img, 15, 5, OUTLINE)
    put(img, 15, 6, OUTLINE)
    put(img, 15, 7, OUTLINE)
    put(img, 32, 5, OUTLINE)
    put(img, 32, 6, OUTLINE)
    put(img, 32, 7, OUTLINE)

    # --- 눈구멍 (소울 빛 타오름) ---
    # 왼쪽
    rect(img, 17, 12, 21, 16, OUTLINE)
    put(img, 18, 13, SOUL_BRIGHT)
    put(img, 19, 13, EYE_CORE)
    put(img, 20, 13, SOUL_BRIGHT)
    put(img, 18, 14, SOUL_MID)
    put(img, 19, 14, SOUL_BRIGHT)
    put(img, 20, 14, SOUL_MID)
    put(img, 19, 15, SOUL_FAINT)
    # 불꽃 (위로 확장)
    put(img, 19, 11, SOUL_FAINT)
    put(img, 18, 10, SOUL_FAINT)

    # 오른쪽
    rect(img, 26, 12, 30, 16, OUTLINE)
    put(img, 27, 13, SOUL_BRIGHT)
    put(img, 28, 13, EYE_CORE)
    put(img, 29, 13, SOUL_BRIGHT)
    put(img, 27, 14, SOUL_MID)
    put(img, 28, 14, SOUL_BRIGHT)
    put(img, 29, 14, SOUL_MID)
    put(img, 28, 15, SOUL_FAINT)
    put(img, 28, 11, SOUL_FAINT)
    put(img, 29, 10, SOUL_FAINT)

    # --- 코 (해골) ---
    put(img, 23, 17, OUTLINE)
    put(img, 24, 17, OUTLINE)

    # --- 이빨 (해골 입) ---
    hline(img, 19, 28, 19, OUTLINE)
    for x in [19, 21, 23, 25, 27]:
        put(img, x, 18, BONE_HI)
    for x in [20, 22, 24, 26, 28]:
        put(img, x, 20, BONE_HI)

    # --- 다중 팔 (6개, 소울 에너지) ---
    # 주 팔 (가장 위, 두꺼움)
    hline(img, 6, 12, 25, DM_HI)
    hline(img, 6, 12, 26, DM_BASE)
    hline(img, 35, 41, 25, DM_HI)
    hline(img, 35, 41, 26, DM_BASE)
    # 주 팔 손 - 소울 에너지
    filled_circle(img, 5, 25, 2, SOUL_MID)
    put(img, 5, 25, SOUL_BRIGHT)
    outline_circle(img, 5, 25, 2, OUTLINE)
    filled_circle(img, 42, 25, 2, SOUL_MID)
    put(img, 42, 25, SOUL_BRIGHT)
    outline_circle(img, 42, 25, 2, OUTLINE)

    # 부 팔1 (중간)
    hline(img, 4, 11, 30, DM_BASE)
    hline(img, 4, 11, 31, DM_SH)
    hline(img, 36, 43, 30, DM_BASE)
    hline(img, 36, 43, 31, DM_SH)
    put(img, 3, 30, SOUL_MID)
    put(img, 3, 31, SOUL_FAINT)
    put(img, 44, 30, SOUL_MID)
    put(img, 44, 31, SOUL_FAINT)

    # 부 팔2 (가장 아래)
    hline(img, 2, 11, 35, DM_SH)
    hline(img, 2, 11, 36, DM_DARK)
    hline(img, 36, 45, 35, DM_SH)
    hline(img, 36, 45, 36, DM_DARK)
    put(img, 1, 35, SOUL_FAINT)
    put(img, 1, 36, SOUL_FAINT)
    put(img, 46, 35, SOUL_FAINT)
    put(img, 46, 36, SOUL_FAINT)

    # --- 다리 (로브에서 살짝 보이는 뼈) ---
    rect(img, 17, 40, 21, 45, BONE_SHADOW)
    rect(img, 26, 40, 30, 45, BONE_SHADOW)
    put(img, 18, 41, BONE_BASE)
    put(img, 27, 41, BONE_BASE)
    hline(img, 16, 22, 46, OUTLINE)
    hline(img, 25, 31, 46, OUTLINE)

    # --- 떠다니는 소울 파티클 (주변 분위기) ---
    for sx, sy in [(2, 12), (45, 10), (1, 42), (46, 40), (10, 2), (37, 1)]:
        put(img, sx, sy, SOUL_FAINT)

    return img


# ============================================================
# 선택 에셋: UI 아이콘 (16x16) — 6종
# ============================================================

def draw_soul_icon():
    """소울 아이콘 — 보라 불꽃 형태."""
    img = create_sprite(16, 16)

    # 불꽃 형태 (아래→위로 좁아지는)
    # 하단 넓은 부분
    put(img, 7, 12, SOUL_FAINT)
    hline(img, 6, 8, 11, SOUL_FAINT)
    hline(img, 5, 9, 10, SOUL_MID)
    hline(img, 5, 9, 9, SOUL_MID)
    # 중간
    hline(img, 5, 9, 8, SOUL_BRIGHT)
    hline(img, 5, 9, 7, SOUL_BRIGHT)
    hline(img, 5, 9, 6, SOUL_BRIGHT)
    # 코어 (가장 밝은)
    put(img, 6, 7, SOUL_WHITE)
    put(img, 7, 6, SOUL_WHITE)
    put(img, 7, 7, SOUL_WHITE)
    # 상단 좁아지는
    hline(img, 6, 8, 5, SOUL_BRIGHT)
    hline(img, 6, 8, 4, SOUL_BRIGHT)
    put(img, 7, 3, SOUL_MID)
    put(img, 7, 2, SOUL_FAINT)

    # 좌우 날림 불꽃
    put(img, 4, 8, SOUL_MID)
    put(img, 3, 7, SOUL_FAINT)
    put(img, 10, 8, SOUL_MID)
    put(img, 11, 7, SOUL_FAINT)

    # 윤곽선
    put(img, 7, 1, OUTLINE)
    put(img, 6, 2, OUTLINE)
    put(img, 8, 2, OUTLINE)
    put(img, 5, 3, OUTLINE)
    put(img, 9, 3, OUTLINE)
    vline(img, 4, 4, 9, OUTLINE)
    vline(img, 10, 4, 9, OUTLINE)
    put(img, 5, 10, OUTLINE)
    put(img, 9, 10, OUTLINE)
    put(img, 4, 10, OUTLINE)
    put(img, 10, 10, OUTLINE)
    put(img, 5, 11, OUTLINE)
    put(img, 9, 11, OUTLINE)
    put(img, 6, 12, OUTLINE)
    put(img, 8, 12, OUTLINE)
    put(img, 7, 13, OUTLINE)

    # 날림 아웃라인
    put(img, 3, 8, OUTLINE)
    put(img, 2, 7, OUTLINE)
    put(img, 11, 8, OUTLINE)
    put(img, 12, 7, OUTLINE)

    return img


def draw_hp_icon():
    """HP 하트 아이콘 — 16x16 비트맵 직접 정의 (아웃라인 빈틈 없음)."""
    img = create_sprite(16, 16)

    # 16x16 하트 비트맵 직접 정의 (클래식 픽셀 하트, 빈틈 없음)
    # _ = transparent, O = outline, R = red, H = highlight, S = shadow
    _ = None
    O = OUTLINE
    R = HP_RED
    H = HP_RED_HI
    S = HP_RED_SHADOW

    bitmap = [
        # 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
        [_, _, O, O, O, _, _, _, _, _, O, O, O, _, _, _],  # 0
        [_, O, H, H, H, O, _, _, _, O, R, R, R, O, _, _],  # 1
        [O, H, H, H, H, H, O, _, O, R, R, R, R, R, O, _],  # 2
        [O, H, H, R, R, R, R, O, R, R, R, R, R, R, O, _],  # 3
        [O, H, R, R, R, R, R, R, R, R, R, R, R, R, O, _],  # 4
        [O, R, R, R, R, R, R, R, R, R, R, R, R, R, O, _],  # 5
        [_, O, R, R, R, R, R, R, R, R, R, R, R, O, _, _],  # 6
        [_, _, O, R, R, R, R, R, R, R, R, R, O, _, _, _],  # 7
        [_, _, _, O, R, R, R, R, R, R, R, O, _, _, _, _],  # 8
        [_, _, _, _, O, R, R, R, R, R, O, _, _, _, _, _],  # 9
        [_, _, _, _, _, O, R, R, R, O, _, _, _, _, _, _],  # 10
        [_, _, _, _, _, _, O, R, O, _, _, _, _, _, _, _],  # 11
        [_, _, _, _, _, _, _, O, _, _, _, _, _, _, _, _],  # 12
        [_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _],  # 13
        [_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _],  # 14
        [_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _],  # 15
    ]

    for y, row in enumerate(bitmap):
        for x, color in enumerate(row):
            if color is not None:
                put(img, x, y, color)

    return img


def draw_ap_icon():
    """AP 마나 드롭 아이콘."""
    img = create_sprite(16, 16)

    # 물방울 형태 (상단 뾰족, 하단 둥근)
    # 내부 채우기
    put(img, 7, 3, AP_BLUE)
    put(img, 8, 3, AP_BLUE)
    hline(img, 6, 9, 4, AP_BLUE)
    hline(img, 5, 10, 5, AP_BLUE)
    hline(img, 4, 11, 6, AP_BLUE)
    hline(img, 4, 11, 7, AP_BLUE)
    hline(img, 4, 11, 8, AP_BLUE)
    hline(img, 4, 11, 9, AP_BLUE)
    hline(img, 4, 11, 10, AP_BLUE)
    hline(img, 5, 10, 11, AP_BLUE)
    hline(img, 6, 9, 12, AP_BLUE)

    # 하이라이트 (좌상)
    put(img, 6, 5, AP_BLUE_HI)
    put(img, 5, 6, AP_BLUE_HI)
    put(img, 5, 7, AP_BLUE_HI)
    put(img, 6, 6, AP_BLUE_HI)
    put(img, 5, 8, AP_BLUE_HI)

    # 반사광 점
    put(img, 6, 7, (200, 220, 255, 255))

    # 그림자 (우하)
    put(img, 10, 9, AP_BLUE_SHADOW)
    put(img, 10, 10, AP_BLUE_SHADOW)
    put(img, 11, 8, AP_BLUE_SHADOW)
    put(img, 11, 9, AP_BLUE_SHADOW)
    put(img, 9, 11, AP_BLUE_SHADOW)

    # 아웃라인
    put(img, 7, 1, OUTLINE)
    put(img, 8, 1, OUTLINE)
    put(img, 6, 2, OUTLINE)
    put(img, 9, 2, OUTLINE)
    put(img, 5, 3, OUTLINE)
    put(img, 10, 3, OUTLINE)
    put(img, 4, 4, OUTLINE)
    put(img, 11, 4, OUTLINE)
    put(img, 3, 5, OUTLINE)
    put(img, 12, 5, OUTLINE)
    vline(img, 3, 6, 10, OUTLINE)
    vline(img, 12, 6, 10, OUTLINE)
    put(img, 4, 11, OUTLINE)
    put(img, 11, 11, OUTLINE)
    put(img, 5, 12, OUTLINE)
    put(img, 10, 12, OUTLINE)
    hline(img, 6, 9, 13, OUTLINE)

    return img


def draw_block_icon():
    """블록(방어) 방패 아이콘."""
    img = create_sprite(16, 16)

    # 방패 형태 (상단 넓고, 하단 뾰족)
    # 내부
    hline(img, 4, 11, 2, BLOCK_GRAY)
    hline(img, 3, 12, 3, BLOCK_GRAY)
    hline(img, 3, 12, 4, BLOCK_GRAY)
    hline(img, 3, 12, 5, BLOCK_GRAY)
    hline(img, 3, 12, 6, BLOCK_GRAY)
    hline(img, 3, 12, 7, BLOCK_GRAY)
    hline(img, 3, 12, 8, BLOCK_GRAY)
    hline(img, 4, 11, 9, BLOCK_GRAY)
    hline(img, 4, 11, 10, BLOCK_GRAY)
    hline(img, 5, 10, 11, BLOCK_GRAY)
    hline(img, 6, 9, 12, BLOCK_GRAY)
    hline(img, 7, 8, 13, BLOCK_GRAY)

    # 하이라이트 (좌상)
    hline(img, 4, 8, 3, BLOCK_GRAY_HI)
    hline(img, 4, 7, 4, BLOCK_GRAY_HI)
    vline(img, 3, 3, 7, BLOCK_GRAY_HI)
    vline(img, 4, 4, 6, BLOCK_GRAY_HI)

    # 그림자 (우하)
    vline(img, 12, 4, 8, BLOCK_GRAY_SH)
    vline(img, 11, 5, 9, BLOCK_GRAY_SH)
    hline(img, 8, 11, 9, BLOCK_GRAY_SH)
    hline(img, 9, 10, 10, BLOCK_GRAY_SH)

    # 중앙 십자 장식
    put(img, 7, 5, BLOCK_GRAY_HI)
    put(img, 8, 5, BLOCK_GRAY_HI)
    put(img, 7, 6, BLOCK_GRAY_HI)
    put(img, 8, 6, BLOCK_GRAY_HI)
    put(img, 7, 7, BLOCK_GRAY_HI)
    put(img, 8, 7, BLOCK_GRAY_HI)
    put(img, 6, 6, BLOCK_GRAY_HI)
    put(img, 9, 6, BLOCK_GRAY_HI)

    # 아웃라인 (연속)
    hline(img, 4, 11, 1, OUTLINE)
    put(img, 3, 2, OUTLINE)
    put(img, 12, 2, OUTLINE)
    vline(img, 2, 3, 8, OUTLINE)
    vline(img, 13, 3, 8, OUTLINE)
    put(img, 3, 9, OUTLINE)
    put(img, 12, 9, OUTLINE)
    put(img, 3, 10, OUTLINE)
    put(img, 12, 10, OUTLINE)
    put(img, 4, 11, OUTLINE)
    put(img, 11, 11, OUTLINE)
    put(img, 5, 12, OUTLINE)
    put(img, 10, 12, OUTLINE)
    put(img, 6, 13, OUTLINE)
    put(img, 9, 13, OUTLINE)
    hline(img, 7, 8, 14, OUTLINE)

    return img


def draw_gold_icon():
    """골드 동전 아이콘."""
    img = create_sprite(16, 16)

    # 동전 원형
    filled_circle(img, 7, 7, 6, GOLD_BASE)
    # 하이라이트 (좌상)
    filled_circle(img, 6, 6, 4, GOLD_HI)
    filled_circle(img, 7, 7, 3, GOLD_BASE)
    # 그림자 (우하)
    for dy in range(3, 6):
        for dx in range(3, 6):
            px, py = 7 + dx - 3, 7 + dy - 3
            if (px - 7) ** 2 + (py - 7) ** 2 <= 36:
                put(img, px, py, GOLD_SHADOW)

    # G 문양
    hline(img, 6, 9, 5, GOLD_DARK)
    put(img, 5, 6, GOLD_DARK)
    put(img, 5, 7, GOLD_DARK)
    put(img, 5, 8, GOLD_DARK)
    hline(img, 6, 9, 9, GOLD_DARK)
    put(img, 9, 8, GOLD_DARK)
    hline(img, 7, 9, 7, GOLD_DARK)

    # 아웃라인
    outline_circle(img, 7, 7, 6, OUTLINE)
    # 테두리 안쪽 링 (입체감)
    outline_circle(img, 7, 7, 5, GOLD_SHADOW)

    return img


def draw_key_icon():
    """열쇠 아이콘."""
    img = create_sprite(16, 16)

    # 열쇠 고리 (원형)
    filled_circle(img, 5, 5, 3, GOLD_BASE)
    filled_circle(img, 5, 5, 1, GOLD_HI)
    outline_circle(img, 5, 5, 3, OUTLINE)
    # 고리 안 구멍
    put(img, 5, 5, GOLD_SHADOW)
    put(img, 5, 4, GOLD_SHADOW)

    # 열쇠 몸통
    hline(img, 8, 13, 5, GOLD_BASE)
    hline(img, 8, 13, 6, GOLD_SHADOW)

    # 이빨 1
    vline(img, 13, 6, 9, GOLD_BASE)
    put(img, 13, 10, OUTLINE)
    put(img, 14, 5, OUTLINE)
    put(img, 14, 6, OUTLINE)
    vline(img, 14, 7, 9, OUTLINE)

    # 이빨 2
    vline(img, 11, 6, 8, GOLD_BASE)
    put(img, 11, 9, OUTLINE)
    put(img, 12, 7, OUTLINE)
    put(img, 12, 8, OUTLINE)

    # 몸통 아웃라인
    hline(img, 8, 13, 4, OUTLINE)
    hline(img, 8, 13, 7, OUTLINE)

    return img


# ============================================================
# 선택 에셋: 카드 타입 아이콘 (12x12) — 3종
# ============================================================

def draw_card_attack():
    """공격 카드 아이콘 — 대각선 검."""
    img = create_sprite(12, 12)

    # 검 날 (대각선 좌하→우상)
    for i in range(8):
        put(img, 2 + i, 9 - i, METAL_HI)
    # 검 날 두께
    for i in range(7):
        put(img, 3 + i, 9 - i, METAL_BASE)

    # 칼끝 (날카로운)
    put(img, 1, 10, METAL_HI)

    # 가드 (십자)
    put(img, 6, 5, GOLD_BASE)
    put(img, 7, 4, GOLD_BASE)
    put(img, 5, 4, GOLD_HI)
    put(img, 8, 5, GOLD_SHADOW)

    # 그립
    put(img, 8, 3, WARRIOR_BASE)
    put(img, 9, 2, WARRIOR_BASE)
    put(img, 10, 1, WARRIOR_SHADOW)

    # 아웃라인 (검 양 옆)
    for i in range(8):
        put(img, 1 + i, 9 - i, OUTLINE)
        if i < 7:
            put(img, 4 + i, 9 - i, OUTLINE)
    put(img, 0, 10, OUTLINE)
    put(img, 0, 11, OUTLINE)
    put(img, 1, 11, OUTLINE)
    put(img, 11, 0, OUTLINE)
    put(img, 11, 1, OUTLINE)
    put(img, 10, 0, OUTLINE)

    return img


def draw_card_skill():
    """스킬 카드 아이콘 — 별/스파클 형태."""
    img = create_sprite(12, 12)

    # 별 (4방향 + 중심)
    cx, cy = 5, 5

    # 세로 축
    put(img, cx, cy - 3, SAGE_ACCENT)
    put(img, cx, cy - 2, SAGE_ACCENT)
    put(img, cx, cy + 2, SAGE_ACCENT)
    put(img, cx, cy + 3, SAGE_ACCENT)

    # 가로 축
    put(img, cx - 3, cy, SAGE_ACCENT)
    put(img, cx - 2, cy, SAGE_ACCENT)
    put(img, cx + 2, cy, SAGE_ACCENT)
    put(img, cx + 3, cy, SAGE_ACCENT)

    # 중간 십자
    put(img, cx, cy - 1, SAGE_HI)
    put(img, cx, cy + 1, SAGE_HI)
    put(img, cx - 1, cy, SAGE_HI)
    put(img, cx + 1, cy, SAGE_HI)

    # 대각선
    put(img, cx - 2, cy - 2, SAGE_BASE)
    put(img, cx + 2, cy - 2, SAGE_BASE)
    put(img, cx - 2, cy + 2, SAGE_BASE)
    put(img, cx + 2, cy + 2, SAGE_BASE)
    put(img, cx - 1, cy - 1, SAGE_HI)
    put(img, cx + 1, cy - 1, SAGE_HI)
    put(img, cx - 1, cy + 1, SAGE_HI)
    put(img, cx + 1, cy + 1, SAGE_HI)

    # 코어 (가장 밝은)
    put(img, cx, cy, EYE_CORE)

    # 아웃라인 (꼭짓점만)
    put(img, cx, cy - 4, OUTLINE)
    put(img, cx, cy + 4, OUTLINE)
    put(img, cx - 4, cy, OUTLINE)
    put(img, cx + 4, cy, OUTLINE)
    put(img, cx - 3, cy - 3, OUTLINE)
    put(img, cx + 3, cy - 3, OUTLINE)
    put(img, cx - 3, cy + 3, OUTLINE)
    put(img, cx + 3, cy + 3, OUTLINE)

    return img


def draw_card_power():
    """파워 카드 아이콘 — 번개 볼트."""
    img = create_sprite(12, 12)

    BOLT_HI = GOLD_HI
    BOLT    = WARRIOR_ACCENT
    BOLT_SH = GOLD_BASE

    # 번개 형태 (위에서 꺾여 아래로)
    # 상단
    hline(img, 5, 8, 0, BOLT_HI)
    hline(img, 4, 7, 1, BOLT_HI)
    hline(img, 3, 6, 2, BOLT)
    hline(img, 2, 5, 3, BOLT)

    # 꺾이는 부분 (가로 돌출)
    hline(img, 3, 8, 4, BOLT)
    hline(img, 4, 9, 5, BOLT_HI)

    # 하단
    hline(img, 5, 8, 6, BOLT)
    hline(img, 4, 7, 7, BOLT)
    hline(img, 3, 6, 8, BOLT_SH)
    hline(img, 2, 5, 9, BOLT_SH)
    put(img, 3, 10, BOLT_SH)
    put(img, 2, 11, BOLT_HI)

    # 아웃라인
    hline(img, 5, 9, -1 + 1, OUTLINE)  # 0행 위 → 실제로 0행은 이미 그려짐
    put(img, 9, 0, OUTLINE)
    put(img, 4, 0, OUTLINE)
    put(img, 3, 1, OUTLINE)
    put(img, 8, 1, OUTLINE)
    put(img, 2, 2, OUTLINE)
    put(img, 7, 2, OUTLINE)
    put(img, 1, 3, OUTLINE)
    put(img, 6, 3, OUTLINE)
    put(img, 1, 4, OUTLINE)
    put(img, 2, 4, OUTLINE)
    put(img, 9, 4, OUTLINE)
    put(img, 3, 5, OUTLINE)
    put(img, 10, 5, OUTLINE)
    put(img, 4, 6, OUTLINE)
    put(img, 9, 6, OUTLINE)
    put(img, 3, 7, OUTLINE)
    put(img, 8, 7, OUTLINE)
    put(img, 2, 8, OUTLINE)
    put(img, 7, 8, OUTLINE)
    put(img, 1, 9, OUTLINE)
    put(img, 6, 9, OUTLINE)
    put(img, 2, 10, OUTLINE)
    put(img, 4, 10, OUTLINE)
    put(img, 1, 11, OUTLINE)
    put(img, 3, 11, OUTLINE)

    return img


# ============================================================
# 선택 에셋: 타이틀 로고 (64x32)
# ============================================================

def draw_title_logo():
    """타이틀 로고 — "SOUL" 크게 + "DUNGEON" 작게 + 소울 불꽃."""
    img = create_sprite(64, 32)

    # 배경 어둠
    rect(img, 0, 0, 63, 31, BG_DARK)

    # --- "SOUL" 대형 글자 (각 ~12px 폭, 10px 높이, y=4~14) ---
    base_y = 4

    # S (x=3~12)
    hline(img, 4, 11, base_y, SOUL_BRIGHT)
    hline(img, 3, 12, base_y + 1, SOUL_BRIGHT)
    vline(img, 3, base_y + 2, base_y + 3, SOUL_BRIGHT)
    hline(img, 4, 11, base_y + 4, SOUL_BRIGHT)
    hline(img, 4, 11, base_y + 5, SOUL_BRIGHT)
    vline(img, 12, base_y + 6, base_y + 7, SOUL_BRIGHT)
    hline(img, 3, 11, base_y + 8, SOUL_BRIGHT)
    hline(img, 4, 12, base_y + 9, SOUL_BRIGHT)
    # S 하이라이트
    put(img, 4, base_y + 1, SOUL_WHITE)
    put(img, 5, base_y + 1, SOUL_WHITE)

    # O (x=14~24)
    hline(img, 16, 22, base_y, SOUL_BRIGHT)
    hline(img, 15, 23, base_y + 1, SOUL_BRIGHT)
    for dy in range(2, 8):
        put(img, 14, base_y + dy, SOUL_BRIGHT)
        put(img, 15, base_y + dy, SOUL_BRIGHT)
        put(img, 23, base_y + dy, SOUL_BRIGHT)
        put(img, 24, base_y + dy, SOUL_BRIGHT)
    hline(img, 15, 23, base_y + 8, SOUL_BRIGHT)
    hline(img, 16, 22, base_y + 9, SOUL_BRIGHT)
    # O 하이라이트
    put(img, 16, base_y + 1, SOUL_WHITE)
    put(img, 15, base_y + 2, SOUL_WHITE)

    # U (x=26~36)
    for dy in range(0, 8):
        put(img, 26, base_y + dy, SOUL_BRIGHT)
        put(img, 27, base_y + dy, SOUL_BRIGHT)
        put(img, 35, base_y + dy, SOUL_BRIGHT)
        put(img, 36, base_y + dy, SOUL_BRIGHT)
    hline(img, 27, 35, base_y + 8, SOUL_BRIGHT)
    hline(img, 28, 34, base_y + 9, SOUL_BRIGHT)
    put(img, 26, base_y, SOUL_WHITE)
    put(img, 27, base_y, SOUL_WHITE)

    # L (x=38~47)
    for dy in range(0, 10):
        put(img, 38, base_y + dy, SOUL_BRIGHT)
        put(img, 39, base_y + dy, SOUL_BRIGHT)
    hline(img, 38, 47, base_y + 8, SOUL_BRIGHT)
    hline(img, 38, 47, base_y + 9, SOUL_BRIGHT)
    put(img, 38, base_y, SOUL_WHITE)
    put(img, 39, base_y, SOUL_WHITE)

    # --- "DUNGEON" 소형 글자 (y=18~24, 각 글자 5px 폭) ---
    y_off = 18
    letters_x = [5, 13, 21, 29, 37, 45, 53]
    c = BONE_BASE
    c_hi = BONE_HI

    for i, ch in enumerate("DUNGEON"):
        x = letters_x[i]
        if ch == 'D':
            vline(img, x, y_off, y_off + 6, c)
            hline(img, x, x + 3, y_off, c)
            hline(img, x, x + 3, y_off + 6, c)
            vline(img, x + 4, y_off + 1, y_off + 5, c)
            put(img, x, y_off, c_hi)
        elif ch == 'U':
            vline(img, x, y_off, y_off + 6, c)
            vline(img, x + 4, y_off, y_off + 6, c)
            hline(img, x, x + 4, y_off + 6, c)
            put(img, x, y_off, c_hi)
        elif ch == 'N':
            vline(img, x, y_off, y_off + 6, c)
            vline(img, x + 4, y_off, y_off + 6, c)
            put(img, x + 1, y_off + 1, c)
            put(img, x + 2, y_off + 2, c)
            put(img, x + 2, y_off + 3, c)
            put(img, x + 3, y_off + 4, c)
            put(img, x, y_off, c_hi)
        elif ch == 'G':
            hline(img, x, x + 4, y_off, c)
            vline(img, x, y_off, y_off + 6, c)
            hline(img, x, x + 4, y_off + 6, c)
            vline(img, x + 4, y_off + 3, y_off + 6, c)
            hline(img, x + 2, x + 4, y_off + 3, c)
            put(img, x, y_off, c_hi)
        elif ch == 'E':
            vline(img, x, y_off, y_off + 6, c)
            hline(img, x, x + 4, y_off, c)
            hline(img, x, x + 3, y_off + 3, c)
            hline(img, x, x + 4, y_off + 6, c)
            put(img, x, y_off, c_hi)
        elif ch == 'O':
            hline(img, x + 1, x + 3, y_off, c)
            hline(img, x + 1, x + 3, y_off + 6, c)
            vline(img, x, y_off + 1, y_off + 5, c)
            vline(img, x + 4, y_off + 1, y_off + 5, c)

    # --- 소울 불꽃 ("O" 위에) ---
    flame_x = 19  # O의 중앙 위
    put(img, flame_x, 0, SOUL_WHITE)
    put(img, flame_x - 1, 1, SOUL_BRIGHT)
    put(img, flame_x, 1, SOUL_WHITE)
    put(img, flame_x + 1, 1, SOUL_BRIGHT)
    put(img, flame_x - 1, 2, SOUL_MID)
    put(img, flame_x, 2, SOUL_BRIGHT)
    put(img, flame_x + 1, 2, SOUL_MID)
    put(img, flame_x, 3, SOUL_MID)

    # --- 하단 장식 라인 ---
    hline(img, 2, 61, 27, SOUL_FAINT)

    # --- 테두리 ---
    outline_rect(img, 0, 0, 63, 31, OUTLINE)

    return img


# ============================================================
# 선택 에셋: 층 배경 패턴 (32x32 타일) — 5종
# ============================================================

def draw_floor_bg(floor_base, floor_accent, pattern_type):
    """층별 배경 타일."""
    img = create_sprite(32, 32)
    rect(img, 0, 0, 31, 31, BG_DARK)

    if pattern_type == 'sewer':
        # 하수도: 벽돌 패턴 + 이끼
        brick_sh = (floor_base[0] - 15, floor_base[1] - 15, floor_base[2] - 10, 255)
        for y in range(0, 32, 4):
            hline(img, 0, 31, y, floor_base)
            offset = 8 if (y // 4) % 2 else 0
            for x in range(offset, 32, 16):
                vline(img, x, y, min(y + 3, 31), floor_base)
            # 벽돌 내부 밝기 변화
            for x in range(0, 32, 16):
                bx = x + offset
                if bx < 32:
                    put(img, bx + 2, y + 1, brick_sh)
                    put(img, bx + 6, y + 2, brick_sh)
        # 이끼 반점
        moss = [(5, 6), (18, 14), (10, 22), (26, 28), (2, 18), (28, 8), (14, 30)]
        for mx, my in moss:
            put(img, mx, my, floor_accent)
            put(img, mx + 1, my, (floor_accent[0] - 20, floor_accent[1] - 20,
                                   floor_accent[2] - 10, 255))

    elif pattern_type == 'dungeon':
        # 지하 감옥: 석조 바닥 타일
        for y in range(0, 32, 8):
            for x in range(0, 32, 8):
                outline_rect(img, x, y, x + 7, y + 7, floor_base)
                # 타일 내부 디테일
                put(img, x + 1, y + 1, floor_accent)
                put(img, x + 3, y + 4, (floor_base[0] - 10, floor_base[1] - 10,
                                          floor_base[2] - 10, 255))
                put(img, x + 5, y + 2, (floor_base[0] - 5, floor_base[1] - 5,
                                          floor_base[2] - 5, 255))

    elif pattern_type == 'mine':
        # 마나 광산: 어두운 암벽 + 결정
        base_rock = (30, 25, 45, 255)
        rect(img, 0, 0, 31, 31, base_rock)
        # 암벽 텍스처
        for pos in [(3, 3), (15, 7), (8, 15), (22, 12), (5, 25), (18, 22), (27, 5)]:
            put(img, pos[0], pos[1], (25, 20, 38, 255))
            put(img, pos[0] + 1, pos[1], (35, 30, 52, 255))
        # 결정 (밝은 포인트)
        crystals = [(4, 4), (20, 8), (12, 16), (28, 20), (8, 28), (24, 28)]
        for cx, cy in crystals:
            put(img, cx, cy, floor_accent)
            put(img, cx + 1, cy, floor_accent)
            put(img, cx, cy + 1, floor_base)
            put(img, cx + 1, cy + 1, floor_base)
            # 결정 빛남
            put(img, cx, cy - 1, (floor_accent[0], floor_accent[1], floor_accent[2], 120))

    elif pattern_type == 'temple':
        # 심연 사원: 의식용 타일 + 균열
        for y in range(0, 32, 8):
            for x in range(0, 32, 8):
                outline_rect(img, x, y, x + 7, y + 7, floor_base)
                # 타일 중앙 문양
                put(img, x + 3, y + 3, floor_accent)
                put(img, x + 4, y + 4, floor_accent)
        # 균열 (지그재그)
        for y in range(4, 28):
            x = 15 + (y % 3 - 1)
            put(img, x, y, floor_accent)
            put(img, x + 1, y, (floor_accent[0] - 30, floor_accent[1] - 10,
                                 floor_accent[2] - 15, 255))
        # 두 번째 균열
        for y in range(8, 24):
            x = 24 + (y % 4 - 2)
            put(img, x, y, floor_accent)

    elif pattern_type == 'abyss':
        # 심층: 순수 어둠 + 보라 파티클
        rect(img, 0, 0, 31, 31, (12, 6, 20, 255))
        # 약간 밝은 영역 (불균일한 어둠)
        for pos in [(8, 8), (20, 16), (12, 24)]:
            filled_circle(img, pos[0], pos[1], 4, (18, 10, 28, 255))
        # 소울 파티클
        particles = [(3, 5), (15, 3), (27, 7), (7, 15), (20, 18),
                     (10, 25), (25, 28), (16, 30), (30, 12), (2, 20)]
        for px, py in particles:
            put(img, px, py, floor_accent)
        # 희미한 보라 파티클
        faint = [(6, 10), (22, 5), (28, 22), (13, 18), (4, 28)]
        for px, py in faint:
            put(img, px, py, SOUL_FAINT)

    return img


# ============================================================
# MAIN
# ============================================================
if __name__ == '__main__':
    print("=== Part 3: Bosses + Optional Assets (v2) ===")

    # 보스
    bosses = {
        'slime_king': draw_slime_king,
        'spider_lord': draw_spider_lord,
        'orc_general': draw_orc_general,
        'vampire_lord': draw_vampire_lord,
        'dungeon_master': draw_dungeon_master,
    }
    for name, fn in bosses.items():
        img = fn()
        save_asset(img, f'assets/pixel_art/bosses/{name}.png')
        print(f"  [OK] Boss: {name}")

    # UI 아이콘
    ui_icons = {
        'soul': draw_soul_icon,
        'hp': draw_hp_icon,
        'ap': draw_ap_icon,
        'block': draw_block_icon,
        'gold': draw_gold_icon,
        'key': draw_key_icon,
    }
    for name, fn in ui_icons.items():
        img = fn()
        save_asset(img, f'assets/pixel_art/ui/{name}.png')
        print(f"  [OK] UI: {name}")

    # 카드 타입 아이콘
    card_icons = {
        'attack': draw_card_attack,
        'skill': draw_card_skill,
        'power': draw_card_power,
    }
    for name, fn in card_icons.items():
        img = fn()
        save_asset(img, f'assets/pixel_art/cards/{name}.png')
        print(f"  [OK] Card: {name}")

    # 타이틀 로고
    logo = draw_title_logo()
    save_asset(logo, 'assets/pixel_art/title/soul_dungeon_logo.png')
    # 타이틀은 가로가 길어서 별도 프리뷰
    save_scaled(logo, 'assets/pixel_art/preview/soul_dungeon_logo_preview.png', (512, 256))
    print("  [OK] Title logo")

    # 층 배경 패턴
    floor_patterns = [
        ('floor1_sewer', FLOOR1_BASE, FLOOR1_ACCENT, 'sewer'),
        ('floor2_dungeon', FLOOR2_BASE, FLOOR2_ACCENT, 'dungeon'),
        ('floor3_mine', FLOOR3_BASE, FLOOR3_ACCENT, 'mine'),
        ('floor4_temple', FLOOR4_BASE, FLOOR4_ACCENT, 'temple'),
        ('floor5_abyss', FLOOR5_BASE, FLOOR5_ACCENT, 'abyss'),
    ]
    for name, base, accent, ptype in floor_patterns:
        img = draw_floor_bg(base, accent, ptype)
        save_asset(img, f'assets/pixel_art/backgrounds/{name}.png')
        print(f"  [OK] BG: {name}")

    total = len(bosses) + len(ui_icons) + len(card_icons) + 1 + len(floor_patterns)
    print(f"Part 3 complete: {total} assets")
