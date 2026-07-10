"""공통 팔레트 + 유틸리티 함수."""
from PIL import Image
import os

# ── 윤곽선 & 배경 ──
OUTLINE       = (10, 8, 15, 255)
BG_DARK       = (18, 14, 28, 255)
BG_MID        = (30, 24, 45, 255)
TRANSPARENT   = (0, 0, 0, 0)

# ── 피부/뼈 ──
BONE_HI       = (235, 225, 210, 255)
BONE_BASE     = (200, 185, 165, 255)
BONE_SHADOW   = (145, 130, 110, 255)
BONE_DARK     = (100, 85, 70, 255)

# ── 소울 ──
SOUL_WHITE    = (220, 200, 255, 255)
SOUL_BRIGHT   = (160, 120, 255, 255)
SOUL_MID      = (120, 80, 200, 255)
SOUL_FAINT    = (80, 50, 150, 255)
SOUL_GLOW     = (100, 70, 180, 200)

# ── 눈 ──
EYE_CORE      = (255, 255, 255, 255)
EYE_BRIGHT    = (160, 120, 255, 255)
EYE_RED       = (255, 60, 60, 255)
EYE_GREEN     = (60, 255, 100, 255)
EYE_GOLD      = (255, 210, 60, 255)

# ── 금속 ──
METAL_HI      = (200, 210, 220, 255)
METAL_BASE    = (140, 150, 165, 255)
METAL_SHADOW  = (80, 85, 100, 255)
METAL_DARK    = (50, 52, 65, 255)

# ── 골드 ──
GOLD_HI       = (255, 235, 140, 255)
GOLD_BASE     = (220, 180, 50, 255)
GOLD_SHADOW   = (170, 120, 30, 255)
GOLD_DARK     = (120, 80, 20, 255)

# ── 직업별 색상 ──
WARRIOR_HI     = (180, 70, 60, 255)
WARRIOR_BASE   = (140, 45, 35, 255)
WARRIOR_SHADOW = (90, 25, 20, 255)
WARRIOR_ACCENT = (255, 140, 50, 255)

SAINT_HI       = (240, 230, 200, 255)
SAINT_BASE     = (200, 185, 140, 255)
SAINT_SHADOW   = (150, 130, 90, 255)
SAINT_ACCENT   = (255, 245, 180, 255)

SAGE_HI        = (80, 120, 200, 255)
SAGE_BASE      = (50, 75, 150, 255)
SAGE_SHADOW    = (30, 45, 100, 255)
SAGE_ACCENT    = (120, 180, 255, 255)

ASSASSIN_HI     = (90, 60, 120, 255)
ASSASSIN_BASE   = (60, 35, 85, 255)
ASSASSIN_SHADOW = (35, 20, 55, 255)
ASSASSIN_ACCENT = (0, 230, 120, 255)

GUARDIAN_HI     = (120, 150, 180, 255)
GUARDIAN_BASE   = (80, 100, 135, 255)
GUARDIAN_SHADOW = (45, 60, 90, 255)
GUARDIAN_ACCENT = (180, 220, 255, 255)

WANDERER_HI     = (160, 140, 100, 255)
WANDERER_BASE   = (120, 100, 65, 255)
WANDERER_SHADOW = (75, 60, 40, 255)
WANDERER_ACCENT = (200, 230, 150, 255)

REAPER_HI       = (120, 30, 40, 255)
REAPER_BASE     = (80, 15, 25, 255)
REAPER_SHADOW   = (45, 8, 15, 255)
REAPER_ACCENT   = (255, 50, 80, 255)

ILLUSION_HI     = (150, 80, 180, 255)
ILLUSION_BASE   = (110, 50, 140, 255)
ILLUSION_SHADOW = (70, 30, 95, 255)
ILLUSION_ACCENT = (255, 130, 200, 255)

HARMONY_HI      = (80, 180, 170, 255)
HARMONY_BASE    = (50, 130, 125, 255)
HARMONY_SHADOW  = (30, 80, 75, 255)
HARMONY_ACCENT  = (150, 255, 230, 255)

# ── 층별 색조 ──
FLOOR1_BASE    = (90, 100, 70, 255)
FLOOR1_ACCENT  = (140, 160, 80, 255)

FLOOR2_BASE    = (80, 85, 100, 255)
FLOOR2_ACCENT  = (130, 140, 180, 255)

FLOOR3_BASE    = (60, 50, 120, 255)
FLOOR3_ACCENT  = (120, 160, 255, 255)

FLOOR4_BASE    = (100, 30, 40, 255)
FLOOR4_ACCENT  = (200, 60, 80, 255)

FLOOR5_BASE    = (40, 20, 60, 255)
FLOOR5_ACCENT  = (160, 80, 255, 255)

# ── HP/AP 등 UI 색상 ──
HP_RED         = (220, 50, 50, 255)
HP_RED_HI      = (255, 100, 100, 255)
HP_RED_SHADOW  = (160, 30, 30, 255)
AP_BLUE        = (80, 140, 220, 255)
AP_BLUE_HI     = (130, 180, 255, 255)
AP_BLUE_SHADOW = (40, 90, 160, 255)
BLOCK_GRAY     = (160, 170, 180, 255)
BLOCK_GRAY_HI  = (200, 210, 220, 255)
BLOCK_GRAY_SH  = (100, 110, 120, 255)

# ── 유틸리티 함수 ──

def create_sprite(w, h):
    return Image.new('RGBA', (w, h), TRANSPARENT)

def put(img, x, y, color):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)

def hline(img, x1, x2, y, color):
    for x in range(x1, x2 + 1):
        put(img, x, y, color)

def vline(img, x, y1, y2, color):
    for y in range(y1, y2 + 1):
        put(img, x, y, color)

def rect(img, x1, y1, x2, y2, color):
    for y in range(y1, y2 + 1):
        for x in range(x1, x2 + 1):
            put(img, x, y, color)

def outline_rect(img, x1, y1, x2, y2, color=OUTLINE):
    hline(img, x1, x2, y1, color)
    hline(img, x1, x2, y2, color)
    vline(img, x1, y1, y2, color)
    vline(img, x2, y1, y2, color)

def filled_circle(img, cx, cy, r, color):
    for y in range(-r, r + 1):
        for x in range(-r, r + 1):
            if x * x + y * y <= r * r:
                put(img, cx + x, cy + y, color)

def outline_circle(img, cx, cy, r, color=OUTLINE):
    x, y, d = 0, r, 3 - 2 * r
    while x <= y:
        for px, py in [(x,y),(-x,y),(x,-y),(-x,-y),(y,x),(-y,x),(y,-x),(-y,-x)]:
            put(img, cx+px, cy+py, color)
        if d < 0:
            d += 4 * x + 6
        else:
            d += 4 * (x - y) + 10
            y -= 1
        x += 1

def save_scaled(img, path, target_size):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if isinstance(target_size, tuple):
        scaled = img.resize(target_size, Image.NEAREST)
    else:
        scaled = img.resize((target_size, target_size), Image.NEAREST)
    scaled.save(path)

def save_with_sizes(img, base_dir, name, sizes):
    """Save at multiple sizes + 512 preview."""
    for s in sizes:
        save_scaled(img, f'{base_dir}/{name}.png', s)
    save_scaled(img, f'assets/pixel_art/preview/{name}_preview.png', 512)

def save_asset(img, path):
    """Save single asset at native resolution."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    # Also save 512 preview
    name = os.path.splitext(os.path.basename(path))[0]
    save_scaled(img, f'assets/pixel_art/preview/{name}_preview.png', 512)

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(BASE)
