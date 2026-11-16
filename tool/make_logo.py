"""Generates the Gyan Setu logo and launcher-icon source images.

Motif: an open book (education) carrying a bridge arch (setu) with a rising
marigold sun (a new dawn for rural learners), on the app's blue-teal gradient.

Run:  python tool/make_logo.py
"""
import math
import os

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'logo')
S = 4096  # supersampled canvas, downscaled to 1024 at the end
BLUE = (27, 94, 140)
TEAL = (42, 157, 143)
SUN = (245, 158, 11)
WHITE = (255, 255, 255)
PAGE_SHADE = (220, 236, 244)


def gradient(size):
    img = Image.new('RGB', (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            px[x, y] = tuple(int(BLUE[i] + (TEAL[i] - BLUE[i]) * t) for i in range(3))
    return img


def fast_gradient(size):
    small = gradient(256)
    return small.resize((size, size), Image.BICUBIC)


def bezier(p0, p1, p2, n=60):
    pts = []
    for i in range(n + 1):
        t = i / n
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        pts.append((x, y))
    return pts


def draw_motif(img, scale=1.0):
    """Draws the motif centred on img. Coordinates are on a 1000-unit grid."""
    d = ImageDraw.Draw(img)
    size = img.size[0]
    k = size / 1000 * scale
    off = size / 2 - 500 * k

    def P(x, y):
        return (off + x * k, off + y * k)

    # Rising sun with a soft halo
    for r, a in ():  # halo disabled for a cleaner look
        halo = Image.new('RGBA', img.size, (0, 0, 0, 0))
        ImageDraw.Draw(halo).ellipse([*P(500 - r, 400 - r), *P(500 + r, 400 + r)], fill=(255, 226, 150, a))
        img.alpha_composite(halo)
    d.ellipse([*P(395, 295), *P(605, 505)], fill=SUN)

    # Bridge arch (setu) – thick white arc with hangers and a deck
    w = 40
    arch = bezier((190, 600), (500, 230), (810, 600), 240)
    outer, inner = [], []
    for i, (x, y) in enumerate(arch):
        a, b = arch[max(i - 1, 0)], arch[min(i + 1, len(arch) - 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        n = math.hypot(dx, dy)
        nx, ny = -dy / n * w / 2, dx / n * w / 2
        outer.append(P(x - nx, y - ny))
        inner.append(P(x + nx, y + ny))
    d.polygon(outer + inner[::-1], fill=WHITE)
    for (x, y) in (arch[0], arch[-1]):
        d.ellipse([*P(x - w / 2, y - w / 2), *P(x + w / 2, y + w / 2)], fill=WHITE)
    for hx in (300, 400, 500, 600, 700):
        # find arch y at hx
        y = min(arch, key=lambda p: abs(p[0] - hx))[1]
        d.line([P(hx, y), P(hx, 600)], fill=WHITE, width=int(16 * k))
    d.rounded_rectangle([*P(170, 588), *P(830, 622)], radius=int(17 * k), fill=WHITE)

    # Open book
    left = bezier((500, 680), (340, 620), (170, 660)) + bezier((170, 820), (340, 780), (500, 840))
    right = bezier((500, 680), (660, 620), (830, 660)) + bezier((830, 820), (660, 780), (500, 840))
    gap = 14
    d.polygon([P(x - (gap if x == 500 else 0), y) for x, y in left], fill=WHITE)
    d.polygon([P(x + (gap if x == 500 else 0), y) for x, y in right], fill=PAGE_SHADE)
    # Text lines on the pages
    for i, yy in enumerate((700, 735, 770)):
        d.line([P(250, yy - 18 + i * 2), P(450, yy + 10)], fill=(*BLUE, 255), width=int(10 * k))
        d.line([P(550, yy + 10), P(750, yy - 18 + i * 2)], fill=(*BLUE, 255), width=int(10 * k))


def rounded_mask(size, radius):
    m = Image.new('L', (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


def save(img, name):
    img.resize((1024, 1024), Image.LANCZOS).save(os.path.join(OUT, name))
    print('wrote', name)


def main():
    os.makedirs(OUT, exist_ok=True)
    bg = fast_gradient(S).convert('RGBA')

    # 1. Full-bleed square icon (iOS, legacy Android, web, desktop)
    full = bg.copy()
    draw_motif(full, 0.92)
    save(full, 'icon_full.png')

    # 2. Rounded logo with transparent corners (used inside the app)
    logo = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    logo.paste(full, (0, 0), rounded_mask(S, int(S * 0.23)))
    save(logo, 'logo.png')

    # 3. Adaptive icon layers (Android 8+): motif kept inside the 66% safe zone
    fg = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    draw_motif(fg, 0.62)
    save(fg, 'icon_foreground.png')
    save(bg, 'icon_background.png')


if __name__ == '__main__':
    main()
