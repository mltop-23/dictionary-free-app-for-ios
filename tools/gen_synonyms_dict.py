#!/usr/bin/env python3
"""
Скачивает открытый английский тезаурус (WordNet через zaibacu/thesaurus)
и делает компактный JSON {слово: [синонимы]} для бандла iOS приложения.
"""
import json
import urllib.request
from collections import defaultdict
from pathlib import Path

URL = "https://raw.githubusercontent.com/zaibacu/thesaurus/master/en_thesaurus.jsonl"
OUT = Path(__file__).parent.parent / "Kefir" / "Resources" / "synonyms_en.json"
MAX_SYNS_PER_WORD = 8  # ограничиваем, чтобы не раздувать

def main():
    print(f"Скачиваю тезаурус из {URL}…")
    with urllib.request.urlopen(URL, timeout=120) as resp:
        raw = resp.read().decode("utf-8")

    combined: defaultdict[str, set[str]] = defaultdict(set)
    total_lines = 0
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        total_lines += 1
        word = (obj.get("word") or "").strip().lower()
        syns = obj.get("synonyms") or []
        if not word or not syns:
            continue
        for s in syns:
            s = s.strip().lower()
            if s and s != word and len(s) < 40:
                combined[word].add(s)
    print(f"Обработано строк: {total_lines:,}, слов с синонимами: {len(combined):,}")

    # Преобразуем в list, обрезаем, сортируем
    result: dict[str, list[str]] = {}
    for word, syns in combined.items():
        sorted_syns = sorted(syns)[:MAX_SYNS_PER_WORD]
        if sorted_syns:
            result[word] = sorted_syns

    OUT.parent.mkdir(parents=True, exist_ok=True)
    # separators без пробелов — экономим место
    OUT.write_text(json.dumps(result, ensure_ascii=False, separators=(',', ':')), encoding="utf-8")
    print(f"✅ Сохранено {len(result):,} слов: {OUT}")
    print(f"   Размер: {OUT.stat().st_size // 1024} KB")

if __name__ == "__main__":
    main()
