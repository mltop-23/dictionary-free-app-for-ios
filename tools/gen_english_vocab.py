#!/usr/bin/env python3
"""
Парсит .md файлы из Obsidian/❤️english/Словарь/ в JSON для приложения.
Формат строки: - [ ] word — перевод (syn: ...)  или с [x]
"""
import json
import re
from pathlib import Path

VOCAB_ROOT = Path("/Users/maksimmalysev/Documents/Obsidian Vault/my_notion/obsidian/❤️english/Словарь")
OUTPUT = Path(__file__).parent.parent / "Kefir" / "Resources" / "english_vocab.json"

# - [ ] word — перевод (syn: ...)
LINE_RE = re.compile(r"^-\s*\[[ x]\]\s*(.+?)\s*[—–-]\s*(.+?)(?:\s*\((.+?)\))?\s*$")
MD_BOLD = re.compile(r"\*\*(.+?)\*\*")
MD_ITALIC = re.compile(r"(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)")

def clean_md(s: str) -> str:
    s = MD_BOLD.sub(r"\1", s)
    s = MD_ITALIC.sub(r"\1", s)
    s = s.replace("**", "").replace("__", "")  # на всякий случай все хвосты
    return s.strip()

def parse_file(path: Path):
    cards = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        m = LINE_RE.match(line)
        if not m:
            continue
        word = clean_md(m.group(1))
        translation = clean_md(m.group(2))
        syn_raw = clean_md(m.group(3) or "")

        # убираем "syn:" и прочее из примера
        example = ""
        if syn_raw:
            if syn_raw.lower().startswith("syn:"):
                example = "Синонимы: " + syn_raw[4:].strip()
            else:
                example = syn_raw
        cards.append({
            "front": word,
            "back": translation,
            "example": example,
        })
    return cards

def pretty_deck_name(folder: str, file_stem: str) -> str:
    # "Verbs1 - Базовые действия (B1-B2)" → "Глаголы: Базовые действия (B1-B2)"
    prefix_map = {
        "Verbs": "Глаголы",
        "Adjective": "Прилаг.",
    }
    # убрать номер/префикс
    name = file_stem
    for p, rus in prefix_map.items():
        if name.startswith(p):
            # отрезать "VerbsN - "
            rest = re.sub(r"^" + p + r"\d*\s*[-–—]\s*", "", name)
            return f"{rus}: {rest}"
    # "01 - Время и пространство" → "Время и пространство"
    cleaned = re.sub(r"^\d+[a-z]?\s*[-–—]\s*", "", name)
    return cleaned

def main():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    result = {"decks": []}

    categories = {
        "Существительные": "Сущ.",
        "Глаголы": "",           # уже в имени файла
        "Прилагательные": "",   # уже в имени файла
        "Выражения": "Выраж.",
    }

    for folder in sorted(VOCAB_ROOT.iterdir()):
        if not folder.is_dir():
            continue
        cat_prefix = categories.get(folder.name, folder.name)
        for md in sorted(folder.glob("*.md")):
            cards = parse_file(md)
            if not cards:
                continue
            deck_name = pretty_deck_name(folder.name, md.stem)
            if cat_prefix and not deck_name.startswith(("Глаголы", "Прилаг.")):
                deck_name = f"{cat_prefix}: {deck_name}"
            result["decks"].append({
                "name": deck_name,
                "category": folder.name,
                "cards": cards,
            })

    total = sum(len(d["cards"]) for d in result["decks"])
    print(f"Колод: {len(result['decks'])}, карточек: {total}")

    OUTPUT.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Сохранено: {OUTPUT}")

if __name__ == "__main__":
    main()
