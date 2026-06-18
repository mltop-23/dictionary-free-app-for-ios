#!/usr/bin/env python3
"""
Генерирует иконку приложения 1024x1024 PNG для MyDict.
Дизайн: градиент фиолет→синий, две буквы A и あ наложены, стопка карточек снизу.
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import subprocess

OUT = Path(__file__).parent.parent / "Kefir" / "Assets.xcassets" / "AppIcon.appiconset" / "Icon-1024.png"

SIZE = 1024

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

def gradient_bg():
    img = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    top = (108, 90, 224)       # фиолетовый
    bottom = (58, 134, 255)     # ярко-синий
    px = img.load()
    for y in range(SIZE):
        t = y / SIZE
        row = lerp(top, bottom, t)
        for x in range(SIZE):
            # лёгкий горизонтальный сдвиг для объёма
            bias = (x / SIZE) * 0.08
            px[x, y] = lerp(row, (255, 255, 255), bias * 0.15)
    return img

def find_font(candidates, size):
    for c in candidates:
        try:
            return ImageFont.truetype(c, size)
        except Exception:
            pass
    return ImageFont.load_default()

def draw_cards(draw):
    # Стопка карточек снизу в стиле Material
    cx, cy = SIZE // 2, int(SIZE * 0.78)
    w, h = 520, 130
    radius = 28
    # три карточки с лёгким смещением
    for i, offset in enumerate([(-30, -50), (10, -25), (0, 0)]):
        x0 = cx - w // 2 + offset[0]
        y0 = cy - h // 2 + offset[1]
        alpha = [0.35, 0.6, 1.0][i]
        color = (255, 255, 255, int(alpha * 255))
        layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        ld.rounded_rectangle([x0, y0, x0 + w, y0 + h], radius=radius, fill=color)
        draw._image.alpha_composite(layer)

def main():
    img = gradient_bg().convert("RGBA")
    draw = ImageDraw.Draw(img)

    # Буквы
    font_paths_latin = [
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/System/Library/Fonts/HelveticaNeue.ttc",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    font_paths_jp = [
        "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
        "/System/Library/Fonts/ヒラギノ丸ゴ ProN W4.ttc",
        "/Library/Fonts/Osaka.ttf",
    ]
    font_big = find_font(font_paths_latin, 620)
    font_jp = find_font(font_paths_jp, 420)

    # "A" по центру, "あ" чуть со сдвигом
    # Смещаем "A" немного влево-вверх, "あ" — вправо-вниз
    a_bbox = draw.textbbox((0, 0), "A", font=font_big)
    a_w = a_bbox[2] - a_bbox[0]
    a_h = a_bbox[3] - a_bbox[1]
    ja_bbox = draw.textbbox((0, 0), "あ", font=font_jp)
    ja_w = ja_bbox[2] - ja_bbox[0]
    ja_h = ja_bbox[3] - ja_bbox[1]

    # Подложка для "A" — более яркая белая
    cx = SIZE // 2
    cy = int(SIZE * 0.44)
    a_x = cx - a_w // 2 - 90 - a_bbox[0]
    a_y = cy - a_h // 2 - a_bbox[1]
    # белая большая A с лёгкой тенью
    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.text((a_x + 10, a_y + 10), "A", font=font_big, fill=(0, 0, 0, 90))
    img.alpha_composite(shadow)
    draw.text((a_x, a_y), "A", font=font_big, fill=(255, 255, 255))

    # "あ" жёлтая, поменьше, справа
    ja_x = cx - ja_w // 2 + 140 - ja_bbox[0]
    ja_y = cy - ja_h // 2 + 80 - ja_bbox[1]
    shadow2 = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sd2 = ImageDraw.Draw(shadow2)
    sd2.text((ja_x + 8, ja_y + 8), "あ", font=font_jp, fill=(0, 0, 0, 100))
    img.alpha_composite(shadow2)
    draw.text((ja_x, ja_y), "あ", font=font_jp, fill=(255, 220, 100))

    # Стопка карточек внизу
    draw_cards(draw)

    # iOS требует непрозрачный фон (RGB)
    final = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    final.paste(img, mask=img.split()[3] if img.mode == "RGBA" else None)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    final.save(OUT, "PNG")
    print(f"Сохранено: {OUT} ({OUT.stat().st_size // 1024} KB)")

if __name__ == "__main__":
    main()
