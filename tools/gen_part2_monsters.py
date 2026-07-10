"""Part 2: 몬스터 초상화 35종 (32x32) — v2 organic shapes."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from pixel_common import *

# ============================================================
# 공통 몬스터 헬퍼
# ============================================================

def eyes_red(img, lx, ly, rx, ry):
    """일반 몬스터 빨간 눈 (2px each)."""
    put(img, lx, ly, EYE_RED); put(img, lx+1, ly, EYE_CORE)
    put(img, rx-1, ry, EYE_CORE); put(img, rx, ry, EYE_RED)

def eyes_gold(img, lx, ly, rx, ry):
    """엘리트 금눈 (2px each)."""
    put(img, lx, ly, EYE_GOLD); put(img, lx+1, ly, EYE_CORE)
    put(img, rx-1, ry, EYE_CORE); put(img, rx, ry, EYE_GOLD)

def crown_gold(img, x1, x2, y):
    """금 왕관 on row y, spikes on y-1."""
    hline(img, x1, x2, y, GOLD_BASE)
    hline(img, x1, x2, y+1, GOLD_SHADOW)
    for x in range(x1+1, x2, 2):
        put(img, x, y-1, GOLD_HI)
        put(img, x, y-2, OUTLINE)
    hline(img, x1, x2, y-1, GOLD_BASE)

def shaded_rect(img, x1, y1, x2, y2, hi, base, sh):
    """3-tone shaded filled rect: hi top-left, sh bottom-right."""
    rect(img, x1, y1, x2, y2, base)
    hline(img, x1, x2-1, y1, hi)
    vline(img, x1, y1, y2-1, hi)
    hline(img, x1+1, x2, y2, sh)
    vline(img, x2, y1+1, y2, sh)

def shaded_circle(img, cx, cy, r, hi, base, sh):
    """Circle with highlight shifted top-left."""
    filled_circle(img, cx, cy, r, base)
    filled_circle(img, cx-1, cy-1, max(1, r-2), hi)
    # shadow crescent bottom-right
    for a in range(-r, r+1):
        for b in range(-r, r+1):
            if a*a + b*b <= r*r and (a+b) > r-1:
                put(img, cx+a, cy+b, sh)

# ============================================================
# 1층 하수도 (FLOOR1_BASE olive green)
# ============================================================

def draw_rat():
    img = create_sprite(32, 32)
    FUR = (110, 95, 75, 255); FUR_HI = (140, 125, 100, 255); FUR_SH = (75, 60, 45, 255)
    # Big round head (SD style)
    filled_circle(img, 13, 14, 5, FUR)
    filled_circle(img, 12, 13, 3, FUR_HI)
    outline_circle(img, 13, 14, 5, OUTLINE)
    # Pointy ears (triangular, not boxy)
    for i in range(3):
        put(img, 10-i, 10-i, FUR_HI); put(img, 9-i, 10-i, OUTLINE)
        put(img, 16+i, 10-i, FUR_HI); put(img, 17+i, 10-i, OUTLINE)
    put(img, 10, 9, OUTLINE); put(img, 16, 9, OUTLINE)
    # Eyes - bright and beady
    put(img, 11, 13, EYE_RED); put(img, 12, 13, EYE_CORE)
    put(img, 14, 13, EYE_CORE); put(img, 15, 13, EYE_RED)
    # Snout
    put(img, 9, 16, FUR_HI); put(img, 10, 16, FUR)
    put(img, 9, 17, OUTLINE); put(img, 8, 16, OUTLINE)
    put(img, 9, 15, (200, 140, 140, 255))  # pink nose
    # Small body (round, not boxy)
    filled_circle(img, 16, 21, 4, FUR)
    filled_circle(img, 15, 20, 2, FUR_HI)
    outline_circle(img, 16, 21, 4, OUTLINE)
    # Four stubby legs
    for lx in [13, 15, 18, 20]:
        vline(img, lx, 24, 26, FUR_SH)
        put(img, lx, 27, OUTLINE)
    # Long curvy tail
    for i, (tx, ty) in enumerate([(21,19),(22,18),(23,17),(24,16),(25,15),(26,15)]):
        put(img, tx, ty, FUR_SH)
        put(img, tx, ty-1, OUTLINE)
    return img

def draw_slime():
    img = create_sprite(32, 32)
    SL = FLOOR1_BASE; SL_HI = (120, 140, 95, 255); SL_SH = (60, 70, 45, 255)
    # Main blob body - big organic circle
    filled_circle(img, 15, 17, 8, SL)
    filled_circle(img, 13, 15, 5, SL_HI)
    # Bottom flat (sitting on ground)
    hline(img, 8, 22, 24, SL_SH)
    hline(img, 9, 21, 25, SL_SH)
    # Drip details
    put(img, 9, 25, SL); put(img, 10, 26, SL); put(img, 10, 27, OUTLINE)
    put(img, 21, 25, SL); put(img, 21, 26, OUTLINE)
    # Outline
    outline_circle(img, 15, 17, 8, OUTLINE)
    hline(img, 8, 22, 25, OUTLINE)
    # Eyes inside - big and cute
    put(img, 12, 15, EYE_RED); put(img, 13, 15, EYE_CORE)
    put(img, 17, 15, EYE_CORE); put(img, 18, 15, EYE_RED)
    # Highlight bubble
    put(img, 11, 12, EYE_CORE); put(img, 12, 11, EYE_CORE)
    # Mouth
    hline(img, 13, 17, 19, SL_SH)
    put(img, 14, 20, SL_SH); put(img, 16, 20, SL_SH)
    return img

def draw_goblin():
    img = create_sprite(32, 32)
    SKIN = (80, 145, 70, 255); SK_HI = (110, 175, 95, 255); SK_SH = (50, 105, 45, 255)
    # Big round head
    filled_circle(img, 15, 11, 6, SKIN)
    filled_circle(img, 14, 10, 3, SK_HI)
    outline_circle(img, 15, 11, 6, OUTLINE)
    # Pointy ears (large, floppy)
    for i in range(4):
        put(img, 8-i, 10+i, SKIN); put(img, 7-i, 10+i, OUTLINE)
        put(img, 22+i, 10+i, SKIN); put(img, 23+i, 10+i, OUTLINE)
    put(img, 8, 9, OUTLINE); put(img, 22, 9, OUTLINE)
    # Eyes
    put(img, 12, 10, EYE_RED); put(img, 13, 10, EYE_CORE)
    put(img, 17, 10, EYE_CORE); put(img, 18, 10, EYE_RED)
    # Mouth with fangs
    hline(img, 13, 17, 14, OUTLINE)
    put(img, 14, 15, BONE_HI); put(img, 16, 15, BONE_HI)
    # Small body
    shaded_rect(img, 12, 17, 18, 23, SK_HI, SKIN, SK_SH)
    outline_rect(img, 11, 17, 19, 24, OUTLINE)
    # Loincloth
    rect(img, 12, 20, 18, 22, FLOOR1_BASE)
    hline(img, 13, 17, 20, FLOOR1_ACCENT)
    # Short sword (right side)
    vline(img, 21, 10, 20, METAL_HI)
    put(img, 21, 9, METAL_BASE)
    put(img, 20, 14, BONE_SHADOW); put(img, 22, 14, BONE_SHADOW)
    # Stubby legs
    rect(img, 12, 24, 14, 27, SK_SH); rect(img, 16, 24, 18, 27, SK_SH)
    hline(img, 11, 14, 28, OUTLINE); hline(img, 16, 19, 28, OUTLINE)
    return img

def draw_toad():
    img = create_sprite(32, 32)
    TD = (70, 125, 60, 255); TD_HI = (100, 155, 85, 255); TD_SH = (45, 90, 40, 255)
    # Wide flat body (elliptical)
    filled_circle(img, 15, 20, 7, TD)
    # Flatten top, extend sides
    rect(img, 8, 18, 22, 24, TD)
    filled_circle(img, 15, 19, 5, TD_HI)
    # Outline body
    outline_circle(img, 15, 20, 7, OUTLINE)
    hline(img, 8, 22, 25, OUTLINE)
    # Protruding eyes (big bulgy)
    filled_circle(img, 11, 14, 2, TD)
    filled_circle(img, 19, 14, 2, TD)
    outline_circle(img, 11, 14, 2, OUTLINE)
    outline_circle(img, 19, 14, 2, OUTLINE)
    put(img, 11, 14, EYE_RED); put(img, 12, 14, EYE_CORE)
    put(img, 19, 14, EYE_CORE); put(img, 18, 14, EYE_RED)
    # Throat pouch
    filled_circle(img, 15, 22, 3, TD_HI)
    # Purple spots on back
    for sx, sy in [(10,18),(14,17),(20,19),(17,21)]:
        put(img, sx, sy, ASSASSIN_BASE)
    # Stubby legs
    rect(img, 7, 24, 10, 27, TD_SH); rect(img, 20, 24, 23, 27, TD_SH)
    put(img, 6, 27, TD_SH); put(img, 24, 27, TD_SH)  # webbed toes
    hline(img, 6, 10, 28, OUTLINE); hline(img, 20, 24, 28, OUTLINE)
    # Poison gas particles
    for gx, gy in [(6,12),(8,10),(24,13),(26,11),(5,17)]:
        put(img, gx, gy, ASSASSIN_ACCENT)
    return img

def draw_bats():
    img = create_sprite(32, 32)
    BAT = (65, 50, 75, 255); BAT_HI = (95, 75, 105, 255)
    def one_bat(cx, cy, span):
        # Body (round, not rect)
        filled_circle(img, cx, cy, 1, BAT)
        put(img, cx, cy-1, BAT_HI)
        # Wings (curved)
        for i in range(1, span+1):
            put(img, cx-i, cy-1, BAT)
            put(img, cx+i, cy-1, BAT)
            if i < span:
                put(img, cx-i, cy-2, BAT_HI)
                put(img, cx+i, cy-2, BAT_HI)
        # Wing tips curve down
        put(img, cx-span, cy, BAT); put(img, cx+span, cy, BAT)
        put(img, cx-span-1, cy, OUTLINE); put(img, cx+span+1, cy, OUTLINE)
        # Top outline
        hline(img, cx-span, cx+span, cy-3, OUTLINE)
        put(img, cx, cy+1, OUTLINE)
        # Eyes
        put(img, cx-1, cy, EYE_RED); put(img, cx+1, cy, EYE_RED)
        # Ear points
        put(img, cx-1, cy-2, OUTLINE); put(img, cx+1, cy-2, OUTLINE)
    one_bat(10, 11, 3)
    one_bat(21, 9, 3)
    one_bat(13, 19, 3)
    one_bat(23, 18, 2)
    return img

def draw_goblin_chief():
    """엘리트: 고블린 족장 — bigger, gold crown."""
    img = create_sprite(32, 32)
    SKIN = (80, 145, 70, 255); SK_HI = (110, 175, 95, 255); SK_SH = (50, 105, 45, 255)
    # Huge head (elite = bigger)
    filled_circle(img, 15, 10, 8, SKIN)
    filled_circle(img, 13, 8, 5, SK_HI)
    outline_circle(img, 15, 10, 8, OUTLINE)
    # Gold crown
    hline(img, 9, 21, 2, GOLD_BASE)
    hline(img, 9, 21, 3, GOLD_SHADOW)
    for x in [10, 13, 16, 19]:
        put(img, x, 1, GOLD_HI); put(img, x, 0, OUTLINE)
    # Big pointy ears
    for i in range(4):
        put(img, 6-i, 8+i, SKIN); put(img, 5-i, 8+i, OUTLINE)
        put(img, 24+i, 8+i, SKIN); put(img, 25+i, 8+i, OUTLINE)
    # Gold eyes (elite)
    eyes_gold(img, 11, 9, 19, 9)
    # Big toothy grin
    hline(img, 12, 18, 14, OUTLINE)
    for x in [12, 14, 16, 18]:
        put(img, x, 15, BONE_HI)
    # Scar on cheek
    put(img, 20, 11, FLOOR1_ACCENT); put(img, 21, 12, FLOOR1_ACCENT)
    # Stocky body
    shaded_rect(img, 10, 18, 20, 25, SK_HI, SKIN, SK_SH)
    outline_rect(img, 9, 18, 21, 26, OUTLINE)
    hline(img, 10, 20, 19, FLOOR1_ACCENT)  # belt
    # Big sword (right)
    vline(img, 24, 6, 24, METAL_HI)
    vline(img, 25, 6, 24, METAL_BASE)
    put(img, 23, 14, GOLD_BASE); put(img, 26, 14, GOLD_BASE)
    put(img, 24, 5, METAL_HI); put(img, 25, 5, METAL_HI)
    # Legs
    rect(img, 10, 26, 13, 29, SK_SH); rect(img, 17, 26, 20, 29, SK_SH)
    hline(img, 10, 13, 30, OUTLINE); hline(img, 17, 20, 30, OUTLINE)
    return img

def draw_sewer_giant():
    """엘리트: 하수도 거인 — huge, pipe weapon, mossy."""
    img = create_sprite(32, 32)
    FL = (125, 105, 85, 255); FL_HI = (155, 135, 110, 255); FL_SH = (85, 70, 55, 255)
    # Huge head
    filled_circle(img, 14, 8, 6, FL)
    filled_circle(img, 13, 7, 3, FL_HI)
    outline_circle(img, 14, 8, 6, OUTLINE)
    # Gold eyes (elite)
    eyes_gold(img, 11, 7, 17, 7)
    # Heavy brow
    hline(img, 10, 18, 5, FL_SH)
    # Wide mouth
    hline(img, 11, 17, 11, OUTLINE)
    hline(img, 11, 17, 12, FL_SH)
    # Massive body (fills most of canvas)
    shaded_rect(img, 6, 14, 22, 26, FL_HI, FL, FL_SH)
    outline_rect(img, 5, 14, 23, 27, OUTLINE)
    # Moss patches
    for mx, my in [(8,16),(14,18),(20,20),(10,23),(18,15)]:
        put(img, mx, my, FLOOR1_ACCENT)
        put(img, mx+1, my, FLOOR1_BASE)
    # Pipe weapon (left hand)
    rect(img, 25, 4, 27, 26, METAL_BASE)
    vline(img, 25, 4, 26, METAL_HI)
    vline(img, 27, 4, 26, METAL_SHADOW)
    outline_rect(img, 24, 3, 28, 27, OUTLINE)
    # Thick legs
    rect(img, 7, 27, 12, 30, FL_SH); rect(img, 16, 27, 21, 30, FL_SH)
    hline(img, 7, 12, 31, OUTLINE); hline(img, 16, 21, 31, OUTLINE)
    return img

# ============================================================
# 2층 지하 감옥 (FLOOR2_BASE cold gray-blue)
# ============================================================

def draw_skeleton():
    img = create_sprite(32, 32)
    # Round skull
    filled_circle(img, 15, 10, 5, BONE_BASE)
    filled_circle(img, 14, 9, 3, BONE_HI)
    outline_circle(img, 15, 10, 5, OUTLINE)
    # Eye sockets (dark holes with red glow)
    rect(img, 12, 8, 14, 10, OUTLINE)
    put(img, 13, 9, EYE_RED)
    rect(img, 16, 8, 18, 10, OUTLINE)
    put(img, 17, 9, EYE_RED)
    # Nose hole + teeth
    put(img, 15, 11, BONE_SHADOW)
    hline(img, 13, 17, 13, BONE_SHADOW)
    for x in [13, 15, 17]:
        put(img, x, 14, BONE_HI)
    # Ribcage body (narrower than head)
    vline(img, 14, 16, 22, BONE_BASE); vline(img, 16, 16, 22, BONE_BASE)
    for y in [16, 18, 20]:
        hline(img, 12, 18, y, BONE_BASE)
    outline_rect(img, 11, 15, 19, 23, OUTLINE)
    # Arms (bony)
    for dy in range(5):
        put(img, 10-dy, 17+dy, BONE_SHADOW)
        put(img, 20+dy, 17+dy, BONE_SHADOW)
    # Sword (right)
    vline(img, 23, 10, 22, METAL_HI)
    put(img, 23, 9, METAL_BASE)
    put(img, 22, 14, GOLD_BASE); put(img, 24, 14, GOLD_BASE)
    # Leg bones
    vline(img, 14, 23, 28, BONE_SHADOW); vline(img, 16, 23, 28, BONE_SHADOW)
    put(img, 13, 29, OUTLINE); put(img, 15, 29, OUTLINE)
    put(img, 17, 29, OUTLINE)
    return img

def draw_ghost():
    img = create_sprite(32, 32)
    GH = (145, 155, 190, 255); GH_HI = (185, 195, 220, 255); GH_SH = (105, 115, 150, 255)
    # Round head top
    filled_circle(img, 15, 12, 7, GH)
    filled_circle(img, 13, 10, 4, GH_HI)
    outline_circle(img, 15, 12, 7, OUTLINE)
    # Flowing body (tapers down)
    for y in range(19, 27):
        w = 7 - (y - 19) // 2
        hline(img, 15-w, 15+w, y, GH_SH if y > 22 else GH)
    # Zigzag bottom hem
    for x in range(9, 22, 2):
        put(img, x, 26, GH_SH)
        put(img, x, 27, OUTLINE)
        put(img, x+1, 25, OUTLINE)
    # Eyes (spooky hollow)
    put(img, 12, 11, EYE_CORE); put(img, 13, 11, EYE_BRIGHT)
    put(img, 17, 11, EYE_BRIGHT); put(img, 18, 11, EYE_CORE)
    # Open mouth (o shape)
    put(img, 14, 15, OUTLINE); put(img, 16, 15, OUTLINE)
    put(img, 15, 16, OUTLINE); put(img, 15, 14, OUTLINE)
    # Wispy arms
    for i in range(3):
        put(img, 8-i, 16+i, GH_SH); put(img, 22+i, 16+i, GH_SH)
    return img

def draw_spider():
    img = create_sprite(32, 32)
    SP = (65, 55, 75, 255); SP_HI = (95, 80, 105, 255); SP_SH = (38, 32, 48, 255)
    # Big round head (SD proportions)
    filled_circle(img, 15, 11, 6, SP)
    filled_circle(img, 14, 10, 3, SP_HI)
    outline_circle(img, 15, 11, 6, OUTLINE)
    # 4 eyes in a row
    for ex in [11, 13, 17, 19]:
        put(img, ex, 10, EYE_RED)
    put(img, 12, 10, EYE_CORE); put(img, 18, 10, EYE_CORE)
    # Fangs
    put(img, 14, 16, SP_HI); put(img, 16, 16, SP_HI)
    put(img, 14, 17, OUTLINE); put(img, 16, 17, OUTLINE)
    # Abdomen (round, smaller)
    filled_circle(img, 15, 22, 4, SP)
    filled_circle(img, 14, 21, 2, SP_HI)
    outline_circle(img, 15, 22, 4, OUTLINE)
    # Abdomen pattern
    put(img, 15, 21, SP_SH); put(img, 14, 23, SP_SH); put(img, 16, 23, SP_SH)
    # 8 legs (curved outward)
    legs = [(-5,-3),(-6,0),(-5,3),(-4,6), (5,-3),(6,0),(5,3),(4,6)]
    for dx, dy in legs:
        bx, by = 15+dx, 15+dy
        put(img, bx, by, SP_SH)
        put(img, bx + (1 if dx > 0 else -1), by, SP_SH)
        put(img, bx + (2 if dx > 0 else -2), by+1, SP_SH)
    return img

def draw_jailer():
    img = create_sprite(32, 32)
    # Heavy helmet (big, covers face)
    shaded_rect(img, 9, 4, 22, 12, METAL_HI, METAL_BASE, METAL_SHADOW)
    outline_rect(img, 8, 3, 23, 13, OUTLINE)
    # T-slit visor
    hline(img, 10, 21, 8, METAL_DARK)
    vline(img, 15, 8, 12, METAL_DARK)
    # Glowing eyes in slit
    put(img, 13, 9, EYE_RED); put(img, 18, 9, EYE_RED)
    # Armored body
    shaded_rect(img, 10, 13, 21, 23, FLOOR2_ACCENT, FLOOR2_BASE, (60,65,80,255))
    outline_rect(img, 9, 13, 22, 24, OUTLINE)
    # Shoulder plates
    rect(img, 8, 13, 10, 16, METAL_BASE); rect(img, 21, 13, 23, 16, METAL_BASE)
    # Key decoration (on belt)
    put(img, 14, 18, GOLD_HI); put(img, 14, 19, GOLD_BASE)
    put(img, 13, 19, GOLD_SHADOW); put(img, 15, 19, GOLD_SHADOW)
    put(img, 14, 20, GOLD_SHADOW)
    # Heavy boots
    rect(img, 10, 24, 14, 28, METAL_SHADOW)
    rect(img, 17, 24, 21, 28, METAL_SHADOW)
    hline(img, 10, 14, 29, OUTLINE); hline(img, 17, 21, 29, OUTLINE)
    return img

def draw_chain_ghost():
    img = create_sprite(32, 32)
    GH = (130, 140, 175, 255); GH_HI = (170, 180, 205, 255); GH_SH = (90, 100, 135, 255)
    # Ghost form (like ghost but with chains)
    filled_circle(img, 15, 12, 7, GH)
    filled_circle(img, 13, 10, 4, GH_HI)
    outline_circle(img, 15, 12, 7, OUTLINE)
    # Flowing bottom
    rect(img, 9, 18, 21, 23, GH)
    for y in range(23, 27):
        w = 6 - (y - 23)
        if w > 0:
            hline(img, 15-w, 15+w, y, GH_SH)
    for x in range(9, 22, 2):
        put(img, x, 26, OUTLINE)
    # Anguished eyes
    put(img, 11, 11, EYE_CORE); put(img, 12, 11, EYE_BRIGHT)
    put(img, 18, 11, EYE_BRIGHT); put(img, 19, 11, EYE_CORE)
    # Screaming mouth
    rect(img, 13, 14, 17, 16, OUTLINE)
    # Chains in X pattern (thick)
    for i in range(8):
        c = METAL_HI if i % 2 == 0 else METAL_BASE
        put(img, 7+i*2, 6+i*2, c); put(img, 8+i*2, 6+i*2, c)
        put(img, 23-i*2, 6+i*2, c); put(img, 22-i*2, 6+i*2, c)
    # Chain links highlight
    for i in range(0, 8, 2):
        put(img, 7+i*2, 6+i*2, METAL_HI)
        put(img, 23-i*2, 6+i*2, METAL_HI)
    return img

def draw_spider_queen():
    """엘리트: 거미 여왕."""
    img = create_sprite(32, 32)
    SP = (75, 60, 90, 255); SP_HI = (105, 85, 120, 255); SP_SH = (45, 35, 60, 255)
    # Huge head (elite size)
    filled_circle(img, 15, 9, 7, SP)
    filled_circle(img, 13, 7, 4, SP_HI)
    outline_circle(img, 15, 9, 7, OUTLINE)
    # Gold crown
    hline(img, 10, 20, 2, GOLD_BASE)
    for x in [11, 15, 19]:
        put(img, x, 1, GOLD_HI); put(img, x, 0, OUTLINE)
    hline(img, 10, 20, 3, GOLD_SHADOW)
    # Gold eyes (elite)
    eyes_gold(img, 11, 8, 19, 8)
    # Extra small eyes
    put(img, 13, 7, EYE_GOLD); put(img, 17, 7, EYE_GOLD)
    # Fangs (prominent)
    put(img, 13, 15, BONE_HI); put(img, 14, 16, OUTLINE)
    put(img, 17, 15, BONE_HI); put(img, 16, 16, OUTLINE)
    # Large abdomen
    filled_circle(img, 15, 22, 6, SP)
    filled_circle(img, 14, 21, 3, SP_HI)
    outline_circle(img, 15, 22, 6, OUTLINE)
    # Egg sac (bumpy bottom)
    for ex, ey in [(13,26),(15,27),(17,26)]:
        filled_circle(img, ex, ey, 1, BONE_HI)
        outline_circle(img, ex, ey, 1, OUTLINE)
    # 8 legs (long, elite-sized)
    for i, dy in enumerate([-2, 1, 4, 7]):
        lx = 6-i; rx = 24+i
        y = 12 + dy
        hline(img, lx, lx+2, y, SP_SH)
        hline(img, rx-2, rx, y, SP_SH)
        put(img, lx-1, y+1, OUTLINE); put(img, rx+1, y+1, OUTLINE)
    return img

def draw_prisoner_king():
    """엘리트: 죄수 왕."""
    img = create_sprite(32, 32)
    FL = (115, 100, 90, 255); FL_HI = (145, 130, 115, 255); FL_SH = (80, 65, 55, 255)
    # Big head
    filled_circle(img, 15, 9, 7, FL)
    filled_circle(img, 14, 8, 4, FL_HI)
    outline_circle(img, 15, 9, 7, OUTLINE)
    # Broken crown
    hline(img, 9, 21, 2, GOLD_BASE)
    put(img, 11, 1, GOLD_HI); put(img, 18, 1, GOLD_HI)
    put(img, 14, 2, OUTLINE); put(img, 15, 1, OUTLINE)  # broken gap
    # Gold eyes (elite)
    eyes_gold(img, 11, 8, 19, 8)
    # Grizzled jaw
    hline(img, 12, 18, 13, FL_SH)
    hline(img, 13, 17, 14, FL_SH)
    # Large armored body
    shaded_rect(img, 8, 16, 22, 25, FL_HI, FLOOR2_BASE, (60,65,80,255))
    outline_rect(img, 7, 16, 23, 26, OUTLINE)
    # Chains on body (vertical on sides)
    for y in range(4, 28, 3):
        put(img, 6, y, METAL_HI); put(img, 24, y, METAL_HI)
    # Chain weapon (right)
    vline(img, 26, 10, 22, METAL_BASE)
    filled_circle(img, 26, 24, 1, METAL_HI)
    outline_circle(img, 26, 24, 1, OUTLINE)
    # Legs
    rect(img, 9, 26, 13, 29, FL_SH); rect(img, 17, 26, 21, 29, FL_SH)
    hline(img, 9, 13, 30, OUTLINE); hline(img, 17, 21, 30, OUTLINE)
    return img

# ============================================================
# 3층 마나 광산 (FLOOR3_BASE purple-blue)
# ============================================================

def draw_golem():
    img = create_sprite(32, 32)
    ST = (125, 130, 138, 255); ST_HI = (160, 165, 172, 255); ST_SH = (85, 90, 98, 255)
    # Angular big head (trapezoid shape)
    rect(img, 10, 5, 21, 13, ST)
    hline(img, 9, 22, 5, ST)  # wider top
    hline(img, 11, 20, 13, ST)  # narrower bottom
    hline(img, 10, 16, 6, ST_HI); vline(img, 10, 6, 12, ST_HI)
    hline(img, 17, 21, 12, ST_SH); vline(img, 21, 6, 12, ST_SH)
    outline_rect(img, 9, 4, 22, 14, OUTLINE)
    # Glowing eyes
    put(img, 12, 9, EYE_RED); put(img, 13, 9, EYE_CORE)
    put(img, 18, 9, EYE_CORE); put(img, 19, 9, EYE_RED)
    # Crack details on face
    put(img, 15, 7, ST_SH); put(img, 16, 8, ST_SH)
    # Massive body
    shaded_rect(img, 7, 15, 24, 26, ST_HI, ST, ST_SH)
    outline_rect(img, 6, 14, 25, 27, OUTLINE)
    # Glowing core (center chest)
    filled_circle(img, 15, 20, 2, FLOOR3_ACCENT)
    put(img, 15, 20, EYE_CORE)
    outline_circle(img, 15, 20, 2, OUTLINE)
    # Stone crack lines on body
    for cx, cy in [(10,18),(20,22),(12,24)]:
        put(img, cx, cy, ST_SH); put(img, cx+1, cy+1, ST_SH)
    # Thick legs
    rect(img, 8, 27, 13, 30, ST_SH); rect(img, 18, 27, 23, 30, ST_SH)
    hline(img, 8, 13, 31, OUTLINE); hline(img, 18, 23, 31, OUTLINE)
    return img

def draw_dark_mage():
    img = create_sprite(32, 32)
    RB = FLOOR3_BASE; RB_HI = (80, 70, 145, 255); RB_SH = (40, 30, 85, 255)
    # Pointed hood
    for i in range(4):
        hline(img, 15-i, 15+i, 4+i, RB)
    put(img, 15, 3, OUTLINE); hline(img, 14, 16, 4, RB_HI)
    # Hood sides
    for y in range(8, 16):
        put(img, 9, y, OUTLINE); put(img, 22, y, OUTLINE)
        hline(img, 10, 21, y, RB)
    vline(img, 10, 8, 15, RB_HI); vline(img, 21, 8, 15, RB_SH)
    hline(img, 9, 22, 16, OUTLINE)
    # Dark face (only eyes visible)
    rect(img, 12, 10, 19, 14, OUTLINE)
    # Glowing purple eyes
    put(img, 14, 11, FLOOR3_ACCENT); put(img, 15, 11, EYE_CORE)
    put(img, 17, 11, EYE_CORE); put(img, 18, 11, FLOOR3_ACCENT)
    # Robe body (flowing)
    for y in range(16, 28):
        w = 6 + (y - 16) // 3
        hline(img, 15-w, 15+w, y, RB)
        put(img, 15-w, y, RB_HI); put(img, 15+w, y, RB_SH)
        put(img, 15-w-1, y, OUTLINE); put(img, 15+w+1, y, OUTLINE)
    hline(img, 8, 22, 28, OUTLINE)
    # Staff (right side)
    vline(img, 24, 4, 26, BONE_SHADOW)
    # Crystal on top of staff
    put(img, 24, 3, FLOOR3_ACCENT); put(img, 23, 4, FLOOR3_ACCENT)
    put(img, 25, 4, FLOOR3_ACCENT); put(img, 24, 2, EYE_CORE)
    # Magic particles
    for px, py in [(7,10),(6,15),(25,18),(26,12)]:
        put(img, px, py, FLOOR3_ACCENT)
    return img

def draw_orc():
    img = create_sprite(32, 32)
    OC = (80, 135, 60, 255); OC_HI = (110, 165, 85, 255); OC_SH = (55, 100, 40, 255)
    # Big blocky head (wider jaw)
    filled_circle(img, 15, 9, 6, OC)
    filled_circle(img, 14, 8, 3, OC_HI)
    outline_circle(img, 15, 9, 6, OUTLINE)
    # Heavy jaw (wider than top)
    rect(img, 10, 12, 20, 15, OC_SH)
    outline_rect(img, 9, 12, 21, 15, OUTLINE)
    # Tusks (upward from jaw)
    put(img, 11, 11, BONE_HI); put(img, 19, 11, BONE_HI)
    put(img, 11, 10, OUTLINE); put(img, 19, 10, OUTLINE)
    # Eyes (small, angry)
    put(img, 12, 8, EYE_RED); put(img, 13, 8, EYE_CORE)
    put(img, 17, 8, EYE_CORE); put(img, 18, 8, EYE_RED)
    # Brow ridge
    hline(img, 11, 19, 6, OC_SH)
    # Muscular body
    shaded_rect(img, 8, 16, 22, 24, OC_HI, OC, OC_SH)
    outline_rect(img, 7, 16, 23, 25, OUTLINE)
    # Shoulder pads
    rect(img, 7, 16, 9, 18, BONE_SHADOW); rect(img, 21, 16, 23, 18, BONE_SHADOW)
    # Axe (right side)
    vline(img, 26, 6, 22, BONE_SHADOW)
    rect(img, 25, 6, 29, 10, METAL_BASE)
    hline(img, 25, 29, 6, METAL_HI)
    outline_rect(img, 24, 5, 30, 11, OUTLINE)
    # Legs
    rect(img, 9, 25, 13, 29, OC_SH); rect(img, 17, 25, 21, 29, OC_SH)
    hline(img, 9, 13, 30, OUTLINE); hline(img, 17, 21, 30, OUTLINE)
    return img

def draw_crystal_orb():
    img = create_sprite(32, 32)
    C1 = FLOOR3_BASE; C2 = FLOOR3_ACCENT; C3 = (80, 100, 205, 255)
    # Main crystal sphere
    filled_circle(img, 15, 15, 9, C1)
    filled_circle(img, 13, 13, 5, C3)
    filled_circle(img, 12, 12, 3, C2)
    outline_circle(img, 15, 15, 9, OUTLINE)
    # Facet lines (crystalline look)
    for i in range(5):
        put(img, 10+i, 8+i, C2)
        put(img, 20-i, 8+i, C3)
    hline(img, 9, 21, 15, C3)
    # Bright core
    put(img, 14, 14, EYE_CORE); put(img, 15, 14, EYE_CORE)
    put(img, 14, 15, EYE_CORE); put(img, 15, 15, EYE_CORE)
    # Two small eyes
    put(img, 11, 13, EYE_RED); put(img, 19, 13, EYE_RED)
    # Highlight sparkle
    put(img, 10, 10, EYE_CORE); put(img, 11, 9, EYE_CORE)
    # Floating crystal shards around
    for sx, sy in [(6,8),(24,10),(5,20),(25,18)]:
        put(img, sx, sy, C2); put(img, sx, sy-1, C3)
    return img

def draw_mana_eater():
    img = create_sprite(32, 32)
    BG = FLOOR3_BASE; BG_HI = (80, 70, 155, 255); BG_SH = (40, 30, 85, 255)
    # Horizontal bug body (segmented, using circles)
    for i, cx in enumerate([10, 15, 20]):
        r = 3 if i == 0 else 4
        filled_circle(img, cx, 18, r, BG)
        if i == 0:
            filled_circle(img, cx-1, 17, 2, BG_HI)
    # Outline around entire body
    outline_circle(img, 10, 18, 3, OUTLINE)
    outline_circle(img, 15, 18, 4, OUTLINE)
    outline_circle(img, 20, 18, 4, OUTLINE)
    # Segment lines
    vline(img, 12, 15, 21, BG_SH); vline(img, 17, 14, 22, BG_SH)
    # Head with big mouth (left)
    rect(img, 3, 14, 8, 22, BG)
    outline_rect(img, 2, 13, 9, 23, OUTLINE)
    # Big open mouth
    hline(img, 2, 6, 17, OUTLINE)
    rect(img, 3, 18, 6, 22, (30, 20, 65, 255))  # dark maw
    # Teeth
    for tx in [3, 5]:
        put(img, tx, 17, BONE_HI)
        put(img, tx, 22, BONE_HI)
    # Eyes
    put(img, 4, 14, FLOOR3_ACCENT); put(img, 6, 14, FLOOR3_ACCENT)
    put(img, 5, 14, EYE_CORE)
    # Mana crystals being eaten
    put(img, 4, 16, FLOOR3_ACCENT); put(img, 5, 15, EYE_CORE)
    # Many legs
    for lx in [9, 13, 17, 21, 24]:
        vline(img, lx, 22, 25, BG_SH)
        put(img, lx, 26, OUTLINE)
    return img

def draw_mimic():
    """엘리트: 미믹."""
    img = create_sprite(32, 32)
    WD = (125, 85, 42, 255); WD_HI = (165, 115, 62, 255); WD_SH = (85, 55, 28, 255)
    # Chest body (rounded corners)
    shaded_rect(img, 6, 15, 25, 26, WD_HI, WD, WD_SH)
    outline_rect(img, 5, 14, 26, 27, OUTLINE)
    # Gold trim
    hline(img, 7, 24, 14, GOLD_BASE)
    hline(img, 7, 24, 15, GOLD_SHADOW)
    # Gold lock
    rect(img, 14, 20, 17, 22, GOLD_HI)
    outline_rect(img, 13, 19, 18, 23, GOLD_SHADOW)
    # Open lid (angled up)
    shaded_rect(img, 6, 6, 25, 14, WD_HI, WD, WD_SH)
    outline_rect(img, 5, 5, 26, 14, OUTLINE)
    hline(img, 7, 24, 6, WD_HI)
    # Teeth row (jagged!)
    for x in range(7, 25):
        if x % 2 == 0:
            put(img, x, 14, BONE_HI)
            put(img, x, 15, BONE_HI)
        else:
            put(img, x, 14, OUTLINE)
    # Bottom teeth
    for x in range(8, 24, 2):
        put(img, x, 15, BONE_HI)
    # Gold eyes (elite)
    eyes_gold(img, 11, 9, 20, 9)
    # Tongue
    put(img, 15, 17, (210, 65, 85, 255))
    put(img, 16, 18, (210, 65, 85, 255))
    put(img, 15, 18, (180, 45, 65, 255))
    # Gold coins spilling
    for gx, gy in [(8, 12), (22, 11), (14, 7)]:
        put(img, gx, gy, GOLD_HI); put(img, gx+1, gy, GOLD_BASE)
    return img

def draw_ancient_guardian():
    """엘리트: 고대 수호자."""
    img = create_sprite(32, 32)
    ST = (105, 110, 120, 255); ST_HI = (145, 150, 160, 255); ST_SH = (70, 75, 85, 255)
    # Huge angular head (fills width)
    shaded_rect(img, 5, 2, 26, 12, ST_HI, ST, ST_SH)
    outline_rect(img, 4, 1, 27, 13, OUTLINE)
    # Rune markings on forehead
    for rx, ry in [(10,4),(15,3),(16,3),(21,4)]:
        put(img, rx, ry, FLOOR3_ACCENT)
    # Gold eyes (elite)
    eyes_gold(img, 10, 7, 21, 7)
    # Massive body
    shaded_rect(img, 4, 13, 27, 26, ST_HI, ST, ST_SH)
    outline_rect(img, 3, 13, 28, 27, OUTLINE)
    # Large glowing core
    filled_circle(img, 15, 19, 3, FLOOR3_ACCENT)
    put(img, 15, 19, EYE_CORE); put(img, 16, 19, EYE_CORE)
    put(img, 15, 20, EYE_CORE); put(img, 16, 20, EYE_CORE)
    outline_circle(img, 15, 19, 3, OUTLINE)
    # Rune markings on body
    for rx, ry in [(7,15),(24,15),(7,24),(24,24),(10,20),(21,20)]:
        put(img, rx, ry, FLOOR3_ACCENT)
    # Shoulder cracks
    for i in range(3):
        put(img, 6+i, 14+i, ST_SH); put(img, 25-i, 14+i, ST_SH)
    # Thick legs
    rect(img, 5, 27, 12, 30, ST_SH); rect(img, 19, 27, 26, 30, ST_SH)
    hline(img, 5, 12, 31, OUTLINE); hline(img, 19, 26, 31, OUTLINE)
    return img

# ============================================================
# 4층 심연 사원 (FLOOR4_BASE red-black)
# ============================================================

def draw_demon():
    img = create_sprite(32, 32)
    DM = FLOOR4_BASE; DM_HI = (140, 48, 58, 255); DM_SH = (68, 20, 28, 255)
    # Horns (curved)
    for i in range(3):
        put(img, 9-i, 4-i, DM_HI); put(img, 8-i, 4-i, OUTLINE)
        put(img, 22+i, 4-i, DM_HI); put(img, 23+i, 4-i, OUTLINE)
    # Round head
    filled_circle(img, 15, 10, 6, DM)
    filled_circle(img, 14, 9, 3, DM_HI)
    outline_circle(img, 15, 10, 6, OUTLINE)
    # Glowing eyes
    put(img, 12, 9, FLOOR4_ACCENT); put(img, 13, 9, EYE_CORE)
    put(img, 17, 9, EYE_CORE); put(img, 18, 9, FLOOR4_ACCENT)
    # Fanged mouth
    hline(img, 13, 17, 13, OUTLINE)
    put(img, 13, 14, BONE_HI); put(img, 17, 14, BONE_HI)
    # Body
    shaded_rect(img, 11, 16, 20, 23, DM_HI, DM, DM_SH)
    outline_rect(img, 10, 16, 21, 24, OUTLINE)
    # Bat wings (curved spread)
    for i in range(5):
        y = 15 + i
        put(img, 9-i, y, DM_SH); put(img, 8-i, y, OUTLINE)
        put(img, 22+i, y, DM_SH); put(img, 23+i, y, OUTLINE)
    # Wing membrane
    for i in range(4):
        put(img, 8-i, 16+i, DM); put(img, 23+i, 16+i, DM)
    # Pointed tail
    for i, (tx, ty) in enumerate([(21,22),(22,23),(23,24),(24,25),(25,25)]):
        put(img, tx, ty, DM_SH)
    put(img, 26, 25, OUTLINE); put(img, 25, 26, OUTLINE)
    # Legs
    rect(img, 12, 24, 14, 27, DM_SH); rect(img, 17, 24, 19, 27, DM_SH)
    hline(img, 12, 14, 28, OUTLINE); hline(img, 17, 19, 28, OUTLINE)
    return img

def draw_gargoyle():
    img = create_sprite(32, 32)
    ST = (115, 120, 128, 255); ST_HI = (150, 155, 162, 255); ST_SH = (78, 83, 90, 255)
    # Squarish head with horns
    shaded_rect(img, 10, 5, 21, 13, ST_HI, ST, ST_SH)
    outline_rect(img, 9, 4, 22, 14, OUTLINE)
    # Small horns
    put(img, 10, 3, ST_SH); put(img, 10, 2, OUTLINE)
    put(img, 21, 3, ST_SH); put(img, 21, 2, OUTLINE)
    # Glowing eyes
    put(img, 13, 8, EYE_RED); put(img, 14, 8, EYE_CORE)
    put(img, 17, 8, EYE_CORE); put(img, 18, 8, EYE_RED)
    # Stone fangs
    hline(img, 13, 18, 12, OUTLINE)
    for x in [14, 16, 18]:
        put(img, x, 13, ST_HI)
    # Heavy body (wider at bottom)
    shaded_rect(img, 8, 14, 23, 24, ST_HI, ST, ST_SH)
    outline_rect(img, 7, 14, 24, 25, OUTLINE)
    # Wide spread wings
    for i in range(6):
        put(img, 6-i, 12+i, ST_SH); put(img, 5-i, 12+i, OUTLINE)
        put(img, 25+i, 12+i, ST_SH); put(img, 26+i, 12+i, OUTLINE)
    # Wing tips (horizontal bar)
    hline(img, 1, 6, 18, ST_SH); hline(img, 25, 30, 18, ST_SH)
    hline(img, 0, 6, 19, OUTLINE); hline(img, 25, 31, 19, OUTLINE)
    # Heavy lower body
    rect(img, 8, 22, 23, 25, ST_SH)
    # Thick legs
    rect(img, 9, 25, 14, 29, ST_SH); rect(img, 17, 25, 22, 29, ST_SH)
    hline(img, 9, 14, 30, OUTLINE); hline(img, 17, 22, 30, OUTLINE)
    return img

def draw_necromancer():
    img = create_sprite(32, 32)
    RB = (52, 28, 38, 255); RB_HI = (82, 42, 52, 255); RB_SH = (32, 14, 22, 255)
    # Hooded head (pointed top)
    for i in range(4):
        hline(img, 15-i, 15+i, 3+i, RB)
    put(img, 15, 2, OUTLINE)
    # Hood sides
    for y in range(7, 16):
        put(img, 9, y, OUTLINE); put(img, 22, y, OUTLINE)
        hline(img, 10, 21, y, RB)
    hline(img, 9, 22, 16, OUTLINE)
    vline(img, 10, 7, 15, RB_HI); vline(img, 21, 7, 15, RB_SH)
    # Outline hood top
    for i in range(4):
        put(img, 15-i-1, 3+i, OUTLINE); put(img, 15+i+1, 3+i, OUTLINE)
    # Dark face (only green eyes visible)
    rect(img, 12, 10, 19, 14, OUTLINE)
    put(img, 14, 11, EYE_GREEN); put(img, 15, 11, EYE_CORE)
    put(img, 17, 11, EYE_CORE); put(img, 18, 11, EYE_GREEN)
    # Robe body (flowing, widens)
    for y in range(16, 28):
        w = 6 + (y - 16) // 3
        hline(img, 15-w, 15+w, y, RB)
        put(img, 15-w, y, RB_HI); put(img, 15+w, y, RB_SH)
        put(img, 15-w-1, y, OUTLINE); put(img, 15+w+1, y, OUTLINE)
    hline(img, 7, 23, 28, OUTLINE)
    # Skull staff
    vline(img, 25, 5, 26, BONE_SHADOW)
    filled_circle(img, 25, 4, 1, BONE_BASE)
    outline_circle(img, 25, 4, 1, OUTLINE)
    put(img, 25, 4, BONE_HI)  # skull highlight
    # Green necro particles
    for px, py in [(6,10),(7,16),(26,14),(4,22)]:
        put(img, px, py, EYE_GREEN)
    return img

def draw_corrupt_priest():
    img = create_sprite(32, 32)
    RB = (165, 145, 105, 255); RB_HI = SAINT_HI; RB_SH = (125, 105, 75, 255)
    CORRUPT = FLOOR4_BASE
    # Hood
    for i in range(3):
        hline(img, 15-i, 15+i, 4+i, RB)
    put(img, 15, 3, OUTLINE)
    for i in range(3):
        put(img, 15-i-1, 4+i, OUTLINE); put(img, 15+i+1, 4+i, OUTLINE)
    # Head
    for y in range(7, 16):
        put(img, 9, y, OUTLINE); put(img, 22, y, OUTLINE)
        hline(img, 10, 21, y, RB)
    hline(img, 9, 22, 16, OUTLINE)
    # Face (pale, sickly)
    rect(img, 12, 10, 19, 14, BONE_BASE)
    hline(img, 12, 16, 10, BONE_HI)
    # Corrupted red eyes
    put(img, 14, 11, EYE_RED); put(img, 15, 11, EYE_CORE)
    put(img, 17, 11, EYE_CORE); put(img, 18, 11, EYE_RED)
    # Robe body
    for y in range(16, 28):
        w = 6 + (y - 16) // 3
        hline(img, 15-w, 15+w, y, RB)
        put(img, 15-w-1, y, OUTLINE); put(img, 15+w+1, y, OUTLINE)
    hline(img, 7, 23, 28, OUTLINE)
    # Corruption stains (spreading red-black)
    for cx, cy in [(11,18),(19,20),(13,24),(17,22),(10,26),(20,17),(15,25)]:
        put(img, cx, cy, CORRUPT)
    # Torn bottom hem
    for x in range(8, 23, 2):
        put(img, x, 27, OUTLINE)
    # Faded holy symbol (corrupted)
    put(img, 15, 18, SAINT_ACCENT); put(img, 16, 18, CORRUPT)
    return img

def draw_shadow_beast():
    img = create_sprite(32, 32)
    DK = (28, 18, 38, 255); DK_HI = (48, 32, 58, 255); DK_SH = (15, 8, 22, 255)
    # Amorphous dark blob (multi-circle)
    filled_circle(img, 15, 16, 8, DK)
    filled_circle(img, 12, 14, 5, DK_HI)
    filled_circle(img, 18, 18, 5, DK)
    outline_circle(img, 15, 16, 8, OUTLINE)
    # Tendrils extending out
    for i in range(4):
        put(img, 6-i, 13+i, DK); put(img, 5-i, 13+i, OUTLINE)
        put(img, 24+i, 11+i, DK); put(img, 25+i, 11+i, OUTLINE)
    put(img, 8, 22, DK); put(img, 7, 23, DK); put(img, 6, 24, OUTLINE)
    # Only red eyes visible in darkness
    put(img, 11, 14, EYE_RED); put(img, 12, 14, EYE_CORE)
    put(img, 18, 14, EYE_CORE); put(img, 19, 14, EYE_RED)
    # Gleaming teeth (crescent mouth)
    hline(img, 12, 19, 19, OUTLINE)
    for x in [13, 15, 17, 19]:
        put(img, x, 18, BONE_HI)
    # Dripping wisps
    for dx, dy in [(10,24),(14,25),(20,23)]:
        put(img, dx, dy, DK_SH); put(img, dx, dy+1, OUTLINE)
    return img

def draw_wraith():
    """엘리트: 원혼 — huge ghost with overlapping faces."""
    img = create_sprite(32, 32)
    WR = (85, 42, 55, 255); WR_HI = (125, 65, 78, 255); WR_SH = (55, 25, 35, 255)
    # Massive ghostly form
    filled_circle(img, 15, 12, 10, WR)
    filled_circle(img, 13, 10, 6, WR_HI)
    outline_circle(img, 15, 12, 10, OUTLINE)
    # Main face
    put(img, 11, 10, EYE_CORE); put(img, 12, 10, FLOOR4_ACCENT)
    put(img, 18, 10, FLOOR4_ACCENT); put(img, 19, 10, EYE_CORE)
    hline(img, 13, 17, 14, OUTLINE)  # mouth
    # Secondary faces (ghostly overlaps)
    put(img, 8, 7, EYE_RED); put(img, 10, 7, EYE_RED)
    put(img, 20, 8, EYE_RED); put(img, 22, 8, EYE_RED)
    put(img, 12, 17, EYE_RED); put(img, 18, 18, EYE_RED)
    # Flowing bottom
    for y in range(22, 28):
        w = 8 - (y - 22)
        if w > 0:
            hline(img, 15-w, 15+w, y, WR_SH)
    for x in range(8, 23, 2):
        put(img, x, 27, WR_SH)
        put(img, x, 28, OUTLINE)
    # Chains (dangling from sides)
    for y in range(3, 27, 2):
        c = METAL_HI if y % 4 == 0 else METAL_BASE
        put(img, 5, y, c); put(img, 25, y, c)
    return img

def draw_abyss_eye():
    """엘리트: 심연의 눈 — giant eyeball + tentacles."""
    img = create_sprite(32, 32)
    # Outer eye (bloodshot)
    filled_circle(img, 15, 13, 10, (65, 28, 38, 255))
    filled_circle(img, 15, 13, 7, (85, 38, 48, 255))
    # Iris
    filled_circle(img, 15, 13, 5, EYE_GOLD)
    filled_circle(img, 15, 13, 4, GOLD_BASE)
    # Pupil
    filled_circle(img, 15, 13, 2, OUTLINE)
    # Highlight
    put(img, 13, 11, EYE_CORE); put(img, 14, 10, EYE_CORE)
    # Outline
    outline_circle(img, 15, 13, 10, OUTLINE)
    # Blood vessel lines
    for bx, by in [(7,8),(8,10),(22,9),(23,12),(7,17),(23,16)]:
        put(img, bx, by, FLOOR4_ACCENT)
    # Tentacles (below, organic curves)
    tentacles = [(9,23),(12,25),(15,26),(18,25),(21,23)]
    for i, (tx, ty) in enumerate(tentacles):
        length = 3 + (i % 2)
        for dy in range(length):
            put(img, tx, ty+dy, FLOOR4_BASE)
            if i % 2 == 0:
                put(img, tx-1, ty+dy, FLOOR4_BASE)
        put(img, tx, ty+length, OUTLINE)
    return img

# ============================================================
# 5층 심층 던전 (FLOOR5_BASE darkness + purple)
# ============================================================

def draw_dark_knight():
    img = create_sprite(32, 32)
    AR = (32, 28, 42, 255); AR_HI = (58, 48, 68, 255); AR_SH = (20, 16, 30, 255)
    # Great helm (rounded top)
    filled_circle(img, 15, 7, 5, AR)
    filled_circle(img, 14, 6, 3, AR_HI)
    rect(img, 10, 7, 20, 11, AR)
    outline_circle(img, 15, 7, 5, OUTLINE)
    outline_rect(img, 9, 7, 21, 12, OUTLINE)
    # T-visor slit
    hline(img, 11, 19, 7, AR_SH)
    vline(img, 15, 7, 11, AR_SH)
    # Purple glowing eyes in slit
    put(img, 13, 8, FLOOR5_ACCENT); put(img, 14, 8, EYE_CORE)
    put(img, 16, 8, EYE_CORE); put(img, 17, 8, FLOOR5_ACCENT)
    # Heavy armor body
    shaded_rect(img, 8, 12, 22, 23, AR_HI, AR, AR_SH)
    outline_rect(img, 7, 12, 23, 24, OUTLINE)
    # Shoulder pauldrons (big, round)
    filled_circle(img, 8, 14, 2, AR_HI)
    outline_circle(img, 8, 14, 2, OUTLINE)
    filled_circle(img, 22, 14, 2, AR_HI)
    outline_circle(img, 22, 14, 2, OUTLINE)
    # Belt / waist detail
    hline(img, 9, 21, 19, AR_SH)
    put(img, 15, 19, GOLD_BASE)
    # Greatsword (right side)
    vline(img, 26, 2, 24, METAL_HI)
    vline(img, 27, 2, 24, METAL_BASE)
    put(img, 25, 12, GOLD_BASE); put(img, 28, 12, GOLD_BASE)
    hline(img, 25, 28, 12, GOLD_SHADOW)
    put(img, 26, 1, METAL_HI); put(img, 27, 1, METAL_HI)
    # Armored legs
    rect(img, 9, 24, 13, 29, AR_SH); rect(img, 17, 24, 21, 29, AR_SH)
    hline(img, 9, 13, 30, OUTLINE); hline(img, 17, 21, 30, OUTLINE)
    return img

def draw_lich():
    img = create_sprite(32, 32)
    RB = FLOOR5_BASE; RB_HI = (65, 38, 88, 255); RB_SH = (28, 14, 42, 255)
    # Crown
    hline(img, 10, 21, 3, GOLD_BASE)
    for x in [12, 16, 20]:
        put(img, x, 2, GOLD_HI); put(img, x, 1, OUTLINE)
    hline(img, 10, 21, 4, GOLD_SHADOW)
    # Skull head (round)
    filled_circle(img, 15, 9, 5, BONE_BASE)
    filled_circle(img, 14, 8, 3, BONE_HI)
    outline_circle(img, 15, 9, 5, OUTLINE)
    # Eye sockets with purple flame
    rect(img, 12, 7, 14, 9, OUTLINE)
    put(img, 13, 8, FLOOR5_ACCENT); put(img, 13, 7, EYE_CORE)
    rect(img, 16, 7, 18, 9, OUTLINE)
    put(img, 17, 8, FLOOR5_ACCENT); put(img, 17, 7, EYE_CORE)
    # Teeth
    hline(img, 13, 17, 12, BONE_SHADOW)
    # Robe body (flowing, no legs - floating)
    for y in range(15, 28):
        w = 5 + (y - 15) // 3
        hline(img, 15-w, 15+w, y, RB)
        put(img, 15-w, y, RB_HI); put(img, 15+w, y, RB_SH)
        put(img, 15-w-1, y, OUTLINE); put(img, 15+w+1, y, OUTLINE)
    # Wispy bottom (floating, no legs)
    for x in range(8, 23, 2):
        put(img, x, 28, RB_SH)
        put(img, x+1, 29, OUTLINE)
    # Purple flame hands
    put(img, 7, 18, FLOOR5_ACCENT); put(img, 6, 17, FLOOR5_ACCENT)
    put(img, 5, 16, EYE_CORE)
    put(img, 24, 18, FLOOR5_ACCENT); put(img, 25, 17, FLOOR5_ACCENT)
    put(img, 26, 16, EYE_CORE)
    # Purple glow particles
    put(img, 8, 14, FLOOR5_ACCENT); put(img, 23, 14, FLOOR5_ACCENT)
    return img

def draw_dragonkin():
    img = create_sprite(32, 32)
    SC = (62, 82, 52, 255); SC_HI = (92, 112, 72, 255); SC_SH = (38, 58, 32, 255)
    # Head with snout
    filled_circle(img, 15, 9, 6, SC)
    filled_circle(img, 14, 8, 3, SC_HI)
    outline_circle(img, 15, 9, 6, OUTLINE)
    # Snout protrusion
    rect(img, 9, 11, 12, 14, SC)
    outline_rect(img, 8, 11, 12, 15, OUTLINE)
    # Horns (curved back)
    put(img, 10, 3, BONE_SHADOW); put(img, 9, 2, BONE_SHADOW); put(img, 9, 1, OUTLINE)
    put(img, 20, 3, BONE_SHADOW); put(img, 21, 2, BONE_SHADOW); put(img, 21, 1, OUTLINE)
    # Fierce eyes
    put(img, 13, 8, EYE_RED); put(img, 14, 8, EYE_CORE)
    put(img, 17, 8, EYE_CORE); put(img, 18, 8, EYE_RED)
    # Fire breath (from snout)
    for fx, fy in [(7,12),(6,11),(5,10),(4,11)]:
        put(img, fx, fy, WARRIOR_ACCENT)
    put(img, 5, 11, WARRIOR_HI); put(img, 6, 10, EYE_CORE)
    # Scaled body
    shaded_rect(img, 10, 15, 21, 24, SC_HI, SC, SC_SH)
    outline_rect(img, 9, 15, 22, 25, OUTLINE)
    # Scale pattern
    for y in [16, 19, 22]:
        for x in range(10, 22, 3):
            put(img, x, y, SC_HI)
    # Small wings
    for i in range(3):
        put(img, 8-i, 15+i, SC_SH); put(img, 7-i, 15+i, OUTLINE)
        put(img, 23+i, 15+i, SC_SH); put(img, 24+i, 15+i, OUTLINE)
    # Tail
    for i, (tx, ty) in enumerate([(22,23),(23,24),(24,25),(25,25),(26,24)]):
        put(img, tx, ty, SC_SH)
    put(img, 27, 24, OUTLINE)
    # Legs
    rect(img, 10, 25, 13, 28, SC_SH); rect(img, 18, 25, 21, 28, SC_SH)
    hline(img, 10, 13, 29, OUTLINE); hline(img, 18, 21, 29, OUTLINE)
    return img

def draw_soul_destroyer():
    img = create_sprite(32, 32)
    AR = (38, 30, 48, 255); AR_HI = (62, 50, 72, 255); AR_SH = (22, 16, 32, 255)
    # Helmet (angular, menacing)
    shaded_rect(img, 10, 3, 21, 12, AR_HI, AR, AR_SH)
    outline_rect(img, 9, 2, 22, 13, OUTLINE)
    # Crest on helmet
    vline(img, 15, 0, 3, AR_HI)
    put(img, 15, 0, OUTLINE); put(img, 14, 1, OUTLINE); put(img, 16, 1, OUTLINE)
    # Eye slit
    hline(img, 11, 20, 7, AR_SH)
    put(img, 14, 8, FLOOR5_ACCENT); put(img, 15, 8, EYE_CORE)
    put(img, 17, 8, EYE_CORE); put(img, 18, 8, FLOOR5_ACCENT)
    # Armored body
    shaded_rect(img, 9, 13, 22, 23, AR_HI, AR, AR_SH)
    outline_rect(img, 8, 13, 23, 24, OUTLINE)
    # Soul weapon (glowing purple blade)
    vline(img, 26, 2, 22, FLOOR5_ACCENT)
    put(img, 25, 2, FLOOR5_ACCENT); put(img, 27, 2, FLOOR5_ACCENT)
    put(img, 26, 1, EYE_CORE)
    vline(img, 25, 4, 22, FLOOR5_BASE); vline(img, 27, 4, 22, FLOOR5_BASE)
    put(img, 26, 23, OUTLINE)
    # Soul particles
    for sx, sy in [(5,8),(6,14),(4,20),(27,10),(28,18)]:
        put(img, sx, sy, SOUL_BRIGHT)
    for sx, sy in [(4,10),(7,18),(28,14)]:
        put(img, sx, sy, SOUL_MID)
    # Legs
    rect(img, 10, 24, 14, 28, AR_SH); rect(img, 17, 24, 21, 28, AR_SH)
    hline(img, 10, 14, 29, OUTLINE); hline(img, 17, 21, 29, OUTLINE)
    return img

def draw_void_weaver():
    img = create_sprite(32, 32)
    SP = (52, 32, 72, 255); SP_HI = (78, 52, 98, 255); SP_SH = (32, 20, 48, 255)
    # Human upper body / head
    filled_circle(img, 15, 8, 5, SP)
    filled_circle(img, 14, 7, 3, SP_HI)
    outline_circle(img, 15, 8, 5, OUTLINE)
    # Face
    rect(img, 12, 8, 18, 11, BONE_BASE)
    hline(img, 12, 15, 8, BONE_HI)
    # Eyes (purple glow)
    put(img, 13, 9, FLOOR5_ACCENT); put(img, 14, 9, EYE_CORE)
    put(img, 16, 9, EYE_CORE); put(img, 17, 9, FLOOR5_ACCENT)
    # Human torso
    shaded_rect(img, 11, 13, 19, 17, SP_HI, SP, SP_SH)
    outline_rect(img, 10, 13, 20, 17, OUTLINE)
    # Spider lower body (big abdomen)
    filled_circle(img, 15, 23, 6, SP)
    filled_circle(img, 14, 22, 3, SP_HI)
    outline_circle(img, 15, 23, 6, OUTLINE)
    # Pattern on abdomen
    put(img, 15, 22, FLOOR5_ACCENT); put(img, 14, 24, SP_SH); put(img, 16, 24, SP_SH)
    # Spider legs (8, spreading out)
    for i, dy in enumerate([-1, 2, 5, 8]):
        lx = 7-i; rx = 23+i
        y = 16 + dy
        put(img, lx, y, SP_SH); put(img, lx-1, y+1, SP_SH)
        put(img, rx, y, SP_SH); put(img, rx+1, y+1, SP_SH)
    # Thread/web effects
    for tx, ty in [(4,6),(3,12),(26,8),(27,15),(2,20)]:
        put(img, tx, ty, FLOOR5_ACCENT)
    return img

def draw_void_walker():
    """엘리트: 공허의 보행자 — huge, half void."""
    img = create_sprite(32, 32)
    VD = (22, 12, 38, 255); VD_HI = (48, 28, 62, 255); VD_SH = (14, 8, 24, 255)
    # Large head (fills top)
    filled_circle(img, 15, 8, 7, VD_HI)
    outline_circle(img, 15, 8, 7, OUTLINE)
    # Left half normal, right half void/darker
    for y in range(1, 16):
        for x in range(16, 23):
            px = img.getpixel((x, y))
            if px[3] > 0 and px != OUTLINE:
                put(img, x, y, VD)
    # Eyes (left normal, right void)
    put(img, 10, 7, FLOOR5_ACCENT); put(img, 11, 7, EYE_CORE)
    put(img, 19, 7, FLOOR5_ACCENT); put(img, 20, 7, FLOOR5_ACCENT)
    # Dimensional rift line (center, glowing)
    for y in range(1, 27):
        put(img, 15, y, FLOOR5_ACCENT)
        if y % 2 == 0:
            put(img, 16, y, FLOOR5_ACCENT)
    # Large body
    shaded_rect(img, 6, 15, 24, 25, VD_HI, VD_HI, VD)
    outline_rect(img, 5, 15, 25, 26, OUTLINE)
    # Right half darker
    rect(img, 16, 16, 24, 24, VD)
    # Re-draw rift line over body
    for y in range(15, 26):
        put(img, 15, y, FLOOR5_ACCENT)
    # Legs
    rect(img, 7, 26, 13, 30, VD_HI); rect(img, 17, 26, 23, 30, VD)
    hline(img, 7, 13, 31, OUTLINE); hline(img, 17, 23, 31, OUTLINE)
    # Void particles (right side)
    for px, py in [(26,10),(27,14),(26,20),(28,18)]:
        put(img, px, py, FLOOR5_ACCENT)
    return img

def draw_dimensional_rift():
    """엘리트: 차원의 균열 — crack shape with eyes/tentacles."""
    img = create_sprite(32, 32)
    VD = (18, 10, 28, 255); RF = FLOOR5_ACCENT
    # Rift shape (vertical jagged crack, organic)
    for y in range(3, 29):
        # Width varies organically
        t = (y - 3) / 25.0
        w = int(3 + 4 * (0.5 - abs(t - 0.5)) * 2)
        # Jagged offset
        off = (y % 3) - 1
        cx = 15 + off
        for x in range(cx - w, cx + w + 1):
            d = abs(x - cx)
            if d <= 1:
                put(img, x, y, VD)  # void center
            elif d <= w - 1:
                put(img, x, y, FLOOR5_BASE)  # rift interior
            elif d == w:
                put(img, x, y, RF)  # glowing edge
            else:
                put(img, x, y, OUTLINE)
    # Outer outline for the rift edges
    for y in range(3, 29):
        t = (y - 3) / 25.0
        w = int(3 + 4 * (0.5 - abs(t - 0.5)) * 2) + 1
        off = (y % 3) - 1
        cx = 15 + off
        put(img, cx - w, y, OUTLINE)
        put(img, cx + w, y, OUTLINE)
    # Eyes inside the rift (multiple, staring out)
    put(img, 14, 10, EYE_CORE); put(img, 16, 10, EYE_CORE)
    put(img, 13, 10, RF); put(img, 17, 10, RF)
    put(img, 15, 14, EYE_RED)  # third eye
    put(img, 14, 20, EYE_CORE); put(img, 16, 20, EYE_CORE)
    # Tentacles reaching out from rift
    for dy in range(5):
        put(img, 11-dy, 16+dy, FLOOR5_BASE)
        put(img, 10-dy, 16+dy, OUTLINE)
    for dy in range(4):
        put(img, 19+dy, 21+dy, FLOOR5_BASE)
        put(img, 20+dy, 21+dy, OUTLINE)
    # Small tentacle top
    for dy in range(3):
        put(img, 18+dy, 8-dy, FLOOR5_BASE)
        put(img, 19+dy, 8-dy, OUTLINE)
    # Glow particles around rift
    for gx, gy in [(8,6),(22,8),(6,18),(24,22),(10,26),(20,4)]:
        put(img, gx, gy, RF)
    return img

# ============================================================
# MAIN
# ============================================================
if __name__ == '__main__':
    print("=== Part 2: 35 Monster Portraits (v2) ===")

    monsters = {
        'floor1': [
            ('rat', draw_rat),
            ('slime', draw_slime),
            ('goblin', draw_goblin),
            ('toad', draw_toad),
            ('bats', draw_bats),
            ('goblin_chief', draw_goblin_chief),
            ('sewer_giant', draw_sewer_giant),
        ],
        'floor2': [
            ('skeleton', draw_skeleton),
            ('ghost', draw_ghost),
            ('spider', draw_spider),
            ('jailer', draw_jailer),
            ('chain_ghost', draw_chain_ghost),
            ('spider_queen', draw_spider_queen),
            ('prisoner_king', draw_prisoner_king),
        ],
        'floor3': [
            ('golem', draw_golem),
            ('dark_mage', draw_dark_mage),
            ('orc', draw_orc),
            ('crystal_orb', draw_crystal_orb),
            ('mana_eater', draw_mana_eater),
            ('mimic', draw_mimic),
            ('ancient_guardian', draw_ancient_guardian),
        ],
        'floor4': [
            ('demon', draw_demon),
            ('gargoyle', draw_gargoyle),
            ('necromancer', draw_necromancer),
            ('corrupt_priest', draw_corrupt_priest),
            ('shadow_beast', draw_shadow_beast),
            ('wraith', draw_wraith),
            ('abyss_eye', draw_abyss_eye),
        ],
        'floor5': [
            ('dark_knight', draw_dark_knight),
            ('lich', draw_lich),
            ('dragonkin', draw_dragonkin),
            ('soul_destroyer', draw_soul_destroyer),
            ('void_weaver', draw_void_weaver),
            ('void_walker', draw_void_walker),
            ('dimensional_rift', draw_dimensional_rift),
        ],
    }

    count = 0
    for floor, mons in monsters.items():
        for name, fn in mons:
            img = fn()
            save_asset(img, f'assets/pixel_art/monsters/{floor}/{name}.png')
            count += 1
            print(f"  [OK] {floor}/{name}")

    print(f"\nPart 2 complete: {count} monster portraits (v2)")
