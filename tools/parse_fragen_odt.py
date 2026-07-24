#!/usr/bin/env python3
"""Parse Fragen.odt (CSV in text:p paragraphs) and export clean RU JSON."""
import csv
import html
import json
import zipfile
from pathlib import Path
import xml.etree.ElementTree as ET

ODT = Path(r"C:\Users\Envy x360\Downloads\Fragen\Fragen.odt")
OUT = Path(__file__).parent / "fragen_odt_clean_ru.json"
NS = {"text": "urn:oasis:names:tc:opendocument:xmlns:text:1.0"}


def clean(s: str) -> str:
    return html.unescape(s.strip().strip('"').strip())


def parse_odt(odt: Path) -> list[dict]:
    with zipfile.ZipFile(odt) as z:
        root = ET.fromstring(z.read("content.xml"))

    rows: list[dict] = []
    for p in root.findall(".//text:p", NS):
        line = "".join(p.itertext()).strip()
        if not line or line.startswith("id,question"):
            continue
        try:
            row = next(csv.reader([line]))
        except csv.Error:
            continue
        if len(row) < 11 or not row[0].isdigit():
            continue
        rows.append(
            {
                "source_id": int(row[0]),
                "question": clean(row[1]),
                "options": [clean(row[i]) for i in range(2, 6)],
                "correct": clean(row[6]),
                "explanation": clean(row[7]),
                "facts": [clean(row[i]) for i in range(8, 11)],
            }
        )
    return rows


def dedupe(rows: list[dict]) -> list[dict]:
    seen: dict[str, dict] = {}
    for r in rows:
        key = r["question"].lower()
        if key not in seen:
            seen[key] = r
    return sorted(seen.values(), key=lambda x: x["source_id"])


def main() -> None:
    rows = parse_odt(ODT)
    unique = dedupe(rows)
    OUT.write_text(json.dumps(unique, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"total rows: {len(rows)}")
    print(f"unique: {len(unique)}")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
