#!/usr/bin/env python3
"""
Берёт любую картинку и превращает в app icon 1024x1024 PNG без прозрачности.
Использование:
    python3 tools/set_app_icon.py <путь к картинке>
Примеры:
    python3 tools/set_app_icon.py ~/Downloads/my_logo.png
    python3 tools/set_app_icon.py ~/Desktop/screenshot.jpg
"""
import sys
from pathlib import Path
from PIL import Image

OUT = Path(__file__).parent.parent / "Kefir" / "Assets.xcassets" / "AppIcon.appiconset" / "Icon-1024.png"

def main():
    if len(sys.argv) < 2:
        print("Использование: python3 set_app_icon.py <путь к картинке>")
        sys.exit(1)

    src = Path(sys.argv[1]).expanduser()
    if not src.exists():
        print(f"Файл не найден: {src}")
        sys.exit(1)

    img = Image.open(src)
    print(f"Исходник: {src.name} ({img.width}×{img.height}, {img.mode})")

    # Приведение к квадрату 1024x1024 (обрезаем по меньшей стороне, центр)
    w, h = img.size
    side = min(w, h)
    left = (w - side) // 2
    top = (h - side) // 2
    img = img.crop((left, top, left + side, top + side))
    img = img.resize((1024, 1024), Image.LANCZOS)

    # Убираем альфу — iOS требует непрозрачный фон. Заливаем белым.
    if img.mode in ("RGBA", "LA", "P"):
        bg = Image.new("RGB", (1024, 1024), (255, 255, 255))
        if img.mode == "P":
            img = img.convert("RGBA")
        bg.paste(img, mask=img.split()[-1] if img.mode == "RGBA" else None)
        img = bg
    else:
        img = img.convert("RGB")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG", optimize=True)
    print(f"✅ Иконка установлена: {OUT.relative_to(Path.cwd()) if OUT.is_relative_to(Path.cwd()) else OUT}")
    print(f"   Размер файла: {OUT.stat().st_size // 1024} KB")
    print("\nДальше в Xcode:")
    print("  1. Cmd+Shift+K (Clean Build Folder)")
    print("  2. Cmd+R")
    print("  3. Удали старое приложение с iPhone и установи заново")

if __name__ == "__main__":
    main()
