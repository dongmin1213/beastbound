"""엘리트 변형 몬스터 5종 전용 픽셀아트 생성.

기존 기본 몹과 이미지를 공유하던 엘리트 5종에 대해 별도 스프라이트를 생성:
1. poison_toad_queen (Floor 1) — 거대 독두꺼비 여왕, 왕관+독 안개
2. dark_archmage (Floor 3) — 대마법사, 보라+금 지팡이
3. chain_wraith (Floor 2) — 사슬 원혼, 붉은 눈+사슬 강조
4. gargoyle_guardian (Floor 4) — 가고일 수호자, 거대+빛나는 룬
5. lich_lord (Floor 5) — 리치 군주, 왕관+보라 오라
"""
from pixel_common import *

SIZE = 32

# ── 색상 팔레트 (엘리트 강조) ──
ELITE_GOLD = (255, 210, 60, 255)
ELITE_GOLD_HI = (255, 235, 140, 255)
ELITE_GOLD_SH = (170, 120, 30, 255)
POISON_GREEN = (80, 200, 60, 255)
POISON_DARK = (40, 120, 30, 255)
POISON_BRIGHT = (140, 255, 80, 255)
TOAD_BODY = (60, 110, 50, 255)
TOAD_BELLY = (120, 160, 80, 255)
TOAD_DARK = (35, 70, 30, 255)
MAGE_ROBE = (60, 30, 100, 255)
MAGE_ROBE_HI = (100, 60, 160, 255)
MAGE_ROBE_SH = (35, 18, 60, 255)
CHAIN_METAL = (160, 170, 180, 255)
CHAIN_DARK = (90, 95, 110, 255)
GHOST_BODY = (140, 160, 200, 200)
GHOST_DARK = (80, 100, 140, 180)
GARGOYLE_STONE = (110, 115, 125, 255)
GARGOYLE_DARK = (70, 72, 80, 255)
GARGOYLE_HI = (160, 165, 175, 255)
RUNE_BLUE = (80, 160, 255, 255)
RUNE_GLOW = (120, 200, 255, 200)
LICH_ROBE = (50, 20, 80, 255)
LICH_ROBE_HI = (80, 40, 120, 255)
LICH_BONE = (200, 185, 165, 255)
LICH_BONE_HI = (235, 225, 210, 255)
AURA_PURPLE = (140, 60, 220, 180)
AURA_BRIGHT = (180, 100, 255, 200)
CROWN_GOLD = (255, 210, 60, 255)
CROWN_HI = (255, 240, 160, 255)

def draw_poison_toad_queen():
    """독두꺼비 여왕 — 기본 두꺼비보다 크고 왕관+독 방울."""
    img = create_sprite(SIZE, SIZE)
    # 독 안개 (배경)
    for x in range(6, 26):
        for y in range(22, 30):
            if (x + y) % 3 == 0:
                put(img, x, y, (40, 120, 30, 80))
    # 몸체 (기본보다 크게)
    rect(img, 8, 12, 23, 24, TOAD_BODY)
    rect(img, 10, 14, 21, 22, TOAD_BELLY)
    # 배 무늬
    for y in range(15, 22, 2):
        hline(img, 12, 19, y, TOAD_BODY)
    # 윤곽
    outline_rect(img, 8, 12, 23, 24, OUTLINE)
    # 머리
    rect(img, 10, 8, 21, 14, TOAD_BODY)
    rect(img, 11, 9, 20, 13, TOAD_BELLY)
    outline_rect(img, 10, 8, 21, 14, OUTLINE)
    # 눈 (크고 불그스레)
    rect(img, 11, 9, 13, 11, EYE_CORE)
    put(img, 12, 10, EYE_RED)
    rect(img, 18, 9, 20, 11, EYE_CORE)
    put(img, 19, 10, EYE_RED)
    # 왕관
    hline(img, 11, 20, 7, CROWN_GOLD)
    hline(img, 11, 20, 8, CROWN_GOLD)
    for x in [12, 15, 18]:
        put(img, x, 5, CROWN_HI)
        put(img, x, 6, CROWN_GOLD)
    # 독 방울 (양 옆)
    filled_circle(img, 6, 18, 2, POISON_GREEN)
    put(img, 6, 17, POISON_BRIGHT)
    filled_circle(img, 25, 16, 2, POISON_GREEN)
    put(img, 25, 15, POISON_BRIGHT)
    # 다리
    rect(img, 9, 24, 11, 28, TOAD_BODY)
    rect(img, 20, 24, 22, 28, TOAD_BODY)
    outline_rect(img, 9, 24, 11, 28, OUTLINE)
    outline_rect(img, 20, 24, 22, 28, OUTLINE)
    # 발가락 독
    for x in [8, 12, 19, 23]:
        put(img, x, 29, POISON_DARK)
    return img

def draw_dark_archmage():
    """대마법사 — 기본 dark_mage보다 거대, 금빛 장식+보라 오라."""
    img = create_sprite(SIZE, SIZE)
    # 보라 오라
    for x in range(4, 28):
        for y in range(2, 30):
            if (x - 16)**2 + (y - 16)**2 < 170 and (x + y) % 4 == 0:
                put(img, x, y, AURA_PURPLE)
    # 로브
    rect(img, 10, 10, 21, 28, MAGE_ROBE)
    rect(img, 11, 11, 20, 27, MAGE_ROBE_HI)
    # 로브 하단 넓어짐
    rect(img, 8, 24, 23, 28, MAGE_ROBE)
    rect(img, 9, 25, 22, 27, MAGE_ROBE_HI)
    outline_rect(img, 8, 24, 23, 28, OUTLINE)
    outline_rect(img, 10, 10, 21, 28, OUTLINE)
    # 금빛 장식 줄
    vline(img, 15, 12, 27, ELITE_GOLD)
    vline(img, 16, 12, 27, ELITE_GOLD)
    hline(img, 10, 21, 16, ELITE_GOLD_SH)
    # 후드
    rect(img, 11, 4, 20, 12, MAGE_ROBE)
    rect(img, 12, 5, 19, 11, MAGE_ROBE_SH)
    outline_rect(img, 11, 4, 20, 12, OUTLINE)
    # 후드 꼭대기
    put(img, 15, 2, MAGE_ROBE)
    put(img, 16, 2, MAGE_ROBE)
    hline(img, 14, 17, 3, MAGE_ROBE)
    # 눈 (보라+금)
    put(img, 13, 8, AURA_BRIGHT)
    put(img, 14, 8, EYE_CORE)
    put(img, 17, 8, EYE_CORE)
    put(img, 18, 8, AURA_BRIGHT)
    # 지팡이 (오른쪽)
    vline(img, 24, 4, 28, ELITE_GOLD_SH)
    vline(img, 25, 4, 28, GOLD_DARK)
    # 지팡이 머리 (수정구)
    filled_circle(img, 24, 3, 2, AURA_BRIGHT)
    put(img, 24, 2, EYE_CORE)
    # 왼손 마법 구체
    filled_circle(img, 7, 16, 3, AURA_PURPLE)
    filled_circle(img, 7, 16, 1, AURA_BRIGHT)
    return img

def draw_chain_wraith():
    """사슬 원혼 — chain_ghost보다 크고 붉은 눈+더 많은 사슬."""
    img = create_sprite(SIZE, SIZE)
    # 유령 몸체 (흔들리는 형태)
    rect(img, 10, 6, 21, 26, GHOST_BODY)
    rect(img, 11, 7, 20, 25, GHOST_DARK)
    # 하단 지그재그
    for x in range(10, 22):
        offset = 1 if x % 2 == 0 else 0
        put(img, x, 26 + offset, GHOST_BODY)
        put(img, x, 27 + offset, GHOST_BODY)
    # 윤곽
    outline_rect(img, 10, 6, 21, 26, OUTLINE)
    # 눈 (붉은색, 크게)
    rect(img, 12, 10, 14, 12, EYE_RED)
    put(img, 13, 11, EYE_CORE)
    rect(img, 17, 10, 19, 12, EYE_RED)
    put(img, 18, 11, EYE_CORE)
    # 입 (으르렁)
    hline(img, 13, 18, 15, OUTLINE)
    put(img, 14, 16, OUTLINE)
    put(img, 17, 16, OUTLINE)
    # 사슬 X 패턴 (크고 촘촘하게)
    for i in range(12):
        x1 = 8 + i
        y1 = 8 + i
        put(img, x1, y1, CHAIN_METAL)
        put(img, x1 + 1, y1, CHAIN_DARK)
        x2 = 23 - i
        put(img, x2, y1, CHAIN_METAL)
        put(img, x2 - 1, y1, CHAIN_DARK)
    # 수평 사슬
    for x in range(6, 26):
        if x % 2 == 0:
            put(img, x, 18, CHAIN_METAL)
        else:
            put(img, x, 18, CHAIN_DARK)
    # 수직 사슬 (양쪽)
    for y in range(4, 28):
        if y % 2 == 0:
            put(img, 8, y, CHAIN_METAL)
            put(img, 23, y, CHAIN_METAL)
        else:
            put(img, 8, y, CHAIN_DARK)
            put(img, 23, y, CHAIN_DARK)
    # 사슬 끝 무게추
    filled_circle(img, 6, 28, 2, CHAIN_METAL)
    put(img, 6, 27, CHAIN_DARK)
    filled_circle(img, 25, 28, 2, CHAIN_METAL)
    put(img, 25, 27, CHAIN_DARK)
    # 붉은 오라
    for x in range(8, 24):
        for y in range(4, 28):
            if (x + y) % 5 == 0 and img.getpixel((x, y))[3] == 0:
                put(img, x, y, (200, 40, 40, 60))
    return img

def draw_gargoyle_guardian():
    """가고일 수호자 — 기본 가고일보다 거대, 빛나는 룬+방패."""
    img = create_sprite(SIZE, SIZE)
    # 몸체 (크게)
    rect(img, 9, 10, 22, 26, GARGOYLE_STONE)
    rect(img, 10, 11, 21, 25, GARGOYLE_DARK)
    outline_rect(img, 9, 10, 22, 26, OUTLINE)
    # 어깨 (넓게)
    rect(img, 6, 10, 9, 16, GARGOYLE_STONE)
    rect(img, 22, 10, 25, 16, GARGOYLE_STONE)
    outline_rect(img, 6, 10, 9, 16, OUTLINE)
    outline_rect(img, 22, 10, 25, 16, OUTLINE)
    # 머리
    rect(img, 11, 4, 20, 11, GARGOYLE_STONE)
    rect(img, 12, 5, 19, 10, GARGOYLE_HI)
    outline_rect(img, 11, 4, 20, 11, OUTLINE)
    # 뿔 (크게)
    vline(img, 10, 1, 5, GARGOYLE_DARK)
    vline(img, 9, 2, 4, GARGOYLE_STONE)
    vline(img, 21, 1, 5, GARGOYLE_DARK)
    vline(img, 22, 2, 4, GARGOYLE_STONE)
    put(img, 10, 1, OUTLINE)
    put(img, 21, 1, OUTLINE)
    # 눈 (룬 빛)
    put(img, 13, 7, RUNE_BLUE)
    put(img, 14, 7, RUNE_GLOW)
    put(img, 17, 7, RUNE_GLOW)
    put(img, 18, 7, RUNE_BLUE)
    # 입 (이빨)
    hline(img, 13, 18, 9, OUTLINE)
    for x in [14, 16, 18]:
        put(img, x, 10, BONE_HI)
    # 날개 (펼침)
    for i in range(6):
        put(img, 5 - i, 8 + i, GARGOYLE_STONE)
        put(img, 4 - i, 8 + i, GARGOYLE_DARK)
        put(img, 26 + i, 8 + i, GARGOYLE_STONE)
        put(img, 27 + i, 8 + i, GARGOYLE_DARK)
    # 룬 (몸체)
    for y in [14, 18, 22]:
        put(img, 15, y, RUNE_BLUE)
        put(img, 16, y, RUNE_GLOW)
    for x in [12, 19]:
        put(img, x, 16, RUNE_BLUE)
        put(img, x, 20, RUNE_BLUE)
    # 방패 (왼팔)
    rect(img, 3, 14, 7, 22, GARGOYLE_HI)
    outline_rect(img, 3, 14, 7, 22, OUTLINE)
    put(img, 5, 18, RUNE_BLUE)
    put(img, 5, 17, RUNE_GLOW)
    put(img, 5, 19, RUNE_GLOW)
    # 다리
    rect(img, 10, 26, 13, 30, GARGOYLE_DARK)
    rect(img, 18, 26, 21, 30, GARGOYLE_DARK)
    outline_rect(img, 10, 26, 13, 30, OUTLINE)
    outline_rect(img, 18, 26, 21, 30, OUTLINE)
    return img

def draw_lich_lord():
    """리치 군주 — 기본 리치보다 거대, 왕관+보라 오라+2개 마법구."""
    img = create_sprite(SIZE, SIZE)
    # 보라 오라 (배경)
    for x in range(4, 28):
        for y in range(0, 30):
            dist = (x - 16)**2 + (y - 15)**2
            if dist < 180 and (x + y) % 3 == 0:
                put(img, x, y, AURA_PURPLE)
    # 로브
    rect(img, 10, 12, 21, 28, LICH_ROBE)
    rect(img, 11, 13, 20, 27, LICH_ROBE_HI)
    # 하단 넓어짐
    rect(img, 8, 24, 23, 30, LICH_ROBE)
    rect(img, 9, 25, 22, 29, LICH_ROBE_HI)
    outline_rect(img, 8, 24, 23, 30, OUTLINE)
    outline_rect(img, 10, 12, 21, 28, OUTLINE)
    # 해골 머리
    rect(img, 11, 4, 20, 13, LICH_BONE)
    rect(img, 12, 5, 19, 12, LICH_BONE_HI)
    outline_rect(img, 11, 4, 20, 13, OUTLINE)
    # 눈구멍
    rect(img, 13, 7, 14, 9, OUTLINE)
    put(img, 13, 8, AURA_BRIGHT)
    rect(img, 17, 7, 18, 9, OUTLINE)
    put(img, 18, 8, AURA_BRIGHT)
    # 코
    put(img, 15, 10, OUTLINE)
    put(img, 16, 10, OUTLINE)
    # 이빨
    hline(img, 13, 18, 12, OUTLINE)
    for x in range(13, 19):
        if x % 2 == 0:
            put(img, x, 13, LICH_BONE_HI)
    # 왕관 (크고 화려)
    hline(img, 10, 21, 4, CROWN_GOLD)
    hline(img, 10, 21, 3, CROWN_GOLD)
    for x in [11, 13, 15, 17, 19]:
        put(img, x, 1, CROWN_HI)
        put(img, x, 2, CROWN_GOLD)
    # 왕관 보석
    put(img, 15, 2, EYE_RED)
    # 마법구 (양손)
    filled_circle(img, 6, 18, 3, AURA_PURPLE)
    filled_circle(img, 6, 18, 1, AURA_BRIGHT)
    put(img, 6, 17, EYE_CORE)
    filled_circle(img, 25, 18, 3, AURA_PURPLE)
    filled_circle(img, 25, 18, 1, AURA_BRIGHT)
    put(img, 25, 17, EYE_CORE)
    # 가슴 룬
    put(img, 15, 16, AURA_BRIGHT)
    put(img, 16, 16, AURA_BRIGHT)
    put(img, 15, 17, AURA_PURPLE)
    put(img, 16, 17, AURA_PURPLE)
    return img


def main():
    print("=== 엘리트 변형 몬스터 5종 픽셀아트 생성 ===")

    sprites = [
        (draw_poison_toad_queen, 'assets/pixel_art/monsters/floor1/toad_queen.png'),
        (draw_dark_archmage, 'assets/pixel_art/monsters/floor3/dark_archmage.png'),
        (draw_chain_wraith, 'assets/pixel_art/monsters/floor2/chain_wraith.png'),
        (draw_gargoyle_guardian, 'assets/pixel_art/monsters/floor4/gargoyle_guardian.png'),
        (draw_lich_lord, 'assets/pixel_art/monsters/floor5/lich_lord.png'),
    ]

    for draw_fn, path in sprites:
        img = draw_fn()
        save_asset(img, path)
        print(f"  OK {path}")

    print(f"\n총 {len(sprites)}종 엘리트 변형 스프라이트 생성 완료.")


if __name__ == '__main__':
    main()
