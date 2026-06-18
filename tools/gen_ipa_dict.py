#!/usr/bin/env python3
"""
Скачивает IPA словарь en_US из open-dict-data/ipa-dict
и сохраняет как JSON {слово: транскрипция} для использования в iOS приложении.
"""
import json
import urllib.request
from pathlib import Path

URL = "https://raw.githubusercontent.com/open-dict-data/ipa-dict/master/data/en_US.txt"
OUT = Path(__file__).parent.parent / "Kefir" / "Resources" / "ipa_en.json"

def main():
    print(f"Скачиваю словарь из {URL}…")
    with urllib.request.urlopen(URL) as resp:
        text = resp.read().decode("utf-8")

    ipa: dict[str, str] = {}
    for line in text.splitlines():
        if "\t" not in line:
            continue
        word, trans = line.split("\t", 1)
        word = word.strip().lower()
        trans = trans.strip()
        # trans может содержать несколько вариантов через ", " — берём первый
        first = trans.split(",")[0].strip()
        # убираем обрамление слэшами: /ðə/ → ðə, но оставляем как есть
        ipa[word] = first

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(ipa, ensure_ascii=False), encoding="utf-8")
    print(f"✅ Сохранено {len(ipa):,} слов: {OUT}")
    print(f"   Размер: {OUT.stat().st_size // 1024} KB")

if __name__ == "__main__":
    main()
