#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Replace bland auto-generated medieval facts in JSON with rich variants."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "lib" / "data" / "Fragen" / "Detailed"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from medieval_auto_terms import rich_facts_for_term, build_auto_concepts  # noqa: E402

TEMPLATE_MARKERS = (
    "было повседневным понятием",
    "war im ",
    " ein grundlegendes Konzept",
    "менялось на протяжении Средневековья",
    "entwickelte sich im Laufe des Mittelalters",
    "Историки используют «",
    "Historiker nutzen den Begriff",
)


def _is_templated(text: str) -> bool:
    return any(m in text for m in TEMPLATE_MARKERS)


def _extract_term(question_de: str) -> str | None:
    m = re.search(r"«([^»]+)»", question_de)
    return m.group(1).strip() if m else None


def _build_term_lookup() -> dict[str, list[dict[str, str]]]:
    lookup: dict[str, list[dict[str, str]]] = {}
    for concept in build_auto_concepts():
        term = _extract_term(concept["q_de"])
        if term:
            lookup[term] = concept["facts"]
    return lookup


def main() -> None:
    lookup = _build_term_lookup()
    total_files = 0
    total_questions = 0

    for path in sorted(DATA_DIR.glob("medieval_*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = 0
        for q in data:
            facts = q.get("interesting_facts") or []
            if not facts:
                continue
            if not any(_is_templated((f.get("de") or "") + (f.get("ru") or "")) for f in facts):
                continue
            term = _extract_term(q.get("question_de") or "")
            if not term or term not in lookup:
                continue
            q["interesting_facts"] = lookup[term]
            changed += 1

        if changed:
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            total_files += 1
            total_questions += changed
            print(f"{path.name}: {changed} questions updated")

    print(f"Done. {total_questions} questions in {total_files} files.")


if __name__ == "__main__":
    main()
