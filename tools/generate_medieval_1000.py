#!/usr/bin/env python3
"""Generate 1000 medieval quiz questions (IDs 6001-7000) in Detailed JSON format."""
from __future__ import annotations

import json
import random
from pathlib import Path

from medieval_entity_data import ENTITIES
from medieval_auto_terms import build_auto_concepts
from medieval_extra_concepts import EXTRA_CONCEPTS

OUT_DIR = Path(__file__).resolve().parent.parent / "lib" / "data" / "Fragen" / "Detailed"
START_ID = 6001
COUNT = 1000
PER_FILE = 100
CATEGORY_DE = "Mittelalter"
CATEGORY_RU = "Средневековье"


def period_label(year: int) -> str:
    if year < 0:
        return f"{-year} BCE"
    return f"{year} CE"


def pick_wrong(pool: list[str], correct: str, n: int = 3) -> list[str]:
    opts = [x for x in pool if x != correct]
    random.shuffle(opts)
    return opts[:n]


def facts_for(entity: dict) -> list[dict[str, str]]:
    return [{"de": entity[f"f{i}_de"], "ru": entity[f"f{i}_ru"]} for i in range(1, 4)]


def base(entity: dict, qid: int, q_de: str, q_ru: str, ans_de: str, ans_ru: str,
         wrong_de: list[str], wrong_ru: list[str], qtype: str, difficulty: str,
         expl_de: str, expl_ru: str, tags: list[str]) -> dict:
    return {
        "id": qid,
        "question_de": q_de,
        "question_ru": q_ru,
        "correct_answer_de": ans_de,
        "correct_answer_ru": ans_ru,
        "wrong_answers_de": wrong_de,
        "wrong_answers_ru": wrong_ru,
        "explanation_de": expl_de,
        "explanation_ru": expl_ru,
        "difficulty": difficulty,
        "category": CATEGORY_RU,
        "type": qtype,
        "period": period_label(entity["year"]),
        "tags": tags,
        "interesting_facts": facts_for(entity),
    }


def build_questions() -> list[dict]:
    questions: list[dict] = []
    name_pool_de = [e["name_de"] for e in ENTITIES]
    name_pool_ru = [e["name_ru"] for e in ENTITIES]
    year_pool_de = [period_label(e["year"]) for e in ENTITIES]
    year_pool_ru = [f"{e['year']} г." if e["year"] > 0 else f"{-e['year']} г. до н.э." for e in ENTITIES]
    place_pool_de = [e["place_de"] for e in ENTITIES]
    place_pool_ru = [e["place_ru"] for e in ENTITIES]

    for entity in ENTITIES:
        y = entity["year"]
        y_de = f"{y} n. Chr." if y > 0 else f"{-y} v. Chr."
        y_ru = f"{y} г." if y > 0 else f"{-y} г. до н.э."
        tags = entity.get("tags", [entity["cat_de"]])

        variants = [
            (
                "factual",
                "medium",
                f"Wer wird vor allem mit {entity['event_de']} in Verbindung gebracht?",
                f"Кто прежде всего связан с событием: {entity['event_ru']}?",
                entity["name_de"],
                entity["name_ru"],
                pick_wrong(name_pool_de, entity["name_de"]),
                pick_wrong(name_pool_ru, entity["name_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "date",
                "medium",
                f"In welchem Jahr fand {entity['event_de']} statt?",
                f"В каком году произошло: {entity['event_ru']}?",
                y_de,
                y_ru,
                pick_wrong(year_pool_de, period_label(y)),
                pick_wrong(year_pool_ru, y_ru),
                f"{entity['expl_de']} Das Ereignis datiert historisch in das Jahr {y_de}.",
                f"{entity['expl_ru']} Событие датируется {y_ru}.",
            ),
            (
                "geography",
                "easy",
                f"Wo spielte sich {entity['event_de']} hauptsächlich ab?",
                f"Где главным образом происходило: {entity['event_ru']}?",
                entity["place_de"],
                entity["place_ru"],
                pick_wrong(place_pool_de, entity["place_de"]),
                pick_wrong(place_pool_ru, entity["place_ru"]),
                f"Der Schwerpunkt lag in {entity['place_de']}. {entity['expl_de']}",
                f"Центр событий — {entity['place_ru']}. {entity['expl_ru']}",
            ),
            (
                "cause_effect",
                "hard",
                f"Was war eine wichtige Folge von {entity['event_de']}?",
                f"Каким было важное следствие: {entity['event_ru']}?",
                entity["effect_de"],
                entity["effect_ru"],
                pick_wrong([e["effect_de"] for e in ENTITIES], entity["effect_de"]),
                pick_wrong([e["effect_ru"] for e in ENTITIES], entity["effect_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "cause_effect",
                "hard",
                f"Was gilt als wesentliche Ursache für {entity['event_de']}?",
                f"Что считается важной причиной: {entity['event_ru']}?",
                entity["cause_de"],
                entity["cause_ru"],
                pick_wrong([e["cause_de"] for e in ENTITIES], entity["cause_de"]),
                pick_wrong([e["cause_ru"] for e in ENTITIES], entity["cause_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "institution",
                "medium",
                f"Welchem Bereich des Mittelalters ordnet man {entity['name_de']} vor allem zu?",
                f"К какой сфере Средневековья прежде всего относят {entity['name_ru']}?",
                entity["cat_de"],
                entity["cat_ru"],
                pick_wrong([e["cat_de"] for e in ENTITIES], entity["cat_de"]),
                pick_wrong([e["cat_ru"] for e in ENTITIES], entity["cat_ru"]),
                f"{entity['name_de']} gehört zum Themenfeld {entity['cat_de']}. {entity['expl_de']}",
                f"{entity['name_ru']} относится к теме «{entity['cat_ru']}». {entity['expl_ru']}",
            ),
            (
                "factual",
                "easy",
                f"Welche Aussage trifft auf {entity['name_de']} zu?",
                f"Какое утверждение верно о {entity['name_ru']}?",
                entity["title_de"],
                entity["title_ru"],
                pick_wrong([e["title_de"] for e in ENTITIES], entity["title_de"]),
                pick_wrong([e["title_ru"] for e in ENTITIES], entity["title_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "military",
                "medium",
                f"Welches Ereignis wird mit {entity['name_de']} verbunden?",
                f"С каким событием связывают {entity['name_ru']}?",
                entity["event_short_de"],
                entity["event_short_ru"],
                pick_wrong([e["event_short_de"] for e in ENTITIES], entity["event_short_de"]),
                pick_wrong([e["event_short_ru"] for e in ENTITIES], entity["event_short_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "factual",
                "medium",
                f"Welcher historische Name passt zum Ereignis «{entity['event_short_de']}»?",
                f"Какое имя соответствует событию «{entity['event_short_ru']}»?",
                entity["name_de"],
                entity["name_ru"],
                pick_wrong(name_pool_de, entity["name_de"]),
                pick_wrong(name_pool_ru, entity["name_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "geography",
                "medium",
                f"Mit welchem Ort verbindet man {entity['name_de']} am häufigsten?",
                f"С каким местом чаще всего связывают {entity['name_ru']}?",
                entity["place_de"],
                entity["place_ru"],
                pick_wrong(place_pool_de, entity["place_de"]),
                pick_wrong(place_pool_ru, entity["place_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "date",
                "hard",
                f"Ungefähr in welcher Zeit lebte oder wirkte {entity['name_de']}?",
                f"Примерно в какое время жил или действовал {entity['name_ru']}?",
                y_de,
                y_ru,
                pick_wrong(year_pool_de, period_label(y)),
                pick_wrong(year_pool_ru, y_ru),
                entity["expl_de"],
                entity["expl_ru"],
            ),
            (
                "cause_effect",
                "medium",
                f"Welche Entwicklung gehört zum Umfeld von {entity['name_de']}?",
                f"Какое развитие относится к контексту {entity['name_ru']}?",
                entity["effect_de"],
                entity["effect_ru"],
                pick_wrong([e["effect_de"] for e in ENTITIES], entity["effect_de"]),
                pick_wrong([e["effect_ru"] for e in ENTITIES], entity["effect_ru"]),
                entity["expl_de"],
                entity["expl_ru"],
            ),
        ]

        for v in variants:
            questions.append(
                base(entity, 0, v[2], v[3], v[4], v[5], v[6], v[7], v[0], v[1], v[8], v[9], tags)
            )

    all_concepts = EXTRA_CONCEPTS + build_auto_concepts()
    term_pool_de = [c["ans_de"] for c in all_concepts]
    term_pool_ru = [c["ans_ru"] for c in all_concepts]

    for concept in all_concepts:
        y = concept["year"]
        y_de = f"{y} n. Chr."
        y_ru = f"{y} г."
        wrong_de = concept.get("wrong_de") or pick_wrong(term_pool_de, concept["ans_de"])
        wrong_ru = concept.get("wrong_ru") or pick_wrong(term_pool_ru, concept["ans_ru"])
        questions.append(
            {
                "id": 0,
                "question_de": concept["q_de"],
                "question_ru": concept["q_ru"],
                "correct_answer_de": concept["ans_de"],
                "correct_answer_ru": concept["ans_ru"],
                "wrong_answers_de": wrong_de,
                "wrong_answers_ru": wrong_ru,
                "explanation_de": concept["expl_de"],
                "explanation_ru": concept["expl_ru"],
                "difficulty": concept.get("difficulty", "medium"),
                "category": CATEGORY_RU,
                "type": concept.get("type", "definition"),
                "period": period_label(y),
                "tags": concept.get("tags", ["Begriff"]),
                "interesting_facts": concept["facts"],
            }
        )

    # Deduplicate by question text
    seen: set[str] = set()
    unique: list[dict] = []
    for q in questions:
        key = q["question_de"]
        if key in seen:
            continue
        seen.add(key)
        unique.append(q)

    random.seed(42)
    random.shuffle(unique)
    return unique[:COUNT]


def main() -> None:
    random.seed(42)
    questions = build_questions()
    if len(questions) < COUNT:
        raise SystemExit(f"Only {len(questions)} unique questions generated, need {COUNT}")

    for i, q in enumerate(questions):
        q["id"] = START_ID + i

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for chunk in range(0, COUNT, PER_FILE):
        batch = questions[chunk : chunk + PER_FILE]
        start = START_ID + chunk
        end = start + len(batch) - 1
        path = OUT_DIR / f"medieval_{start}_{end}.json"
        path.write_text(json.dumps(batch, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"Wrote {path.name} ({len(batch)} questions)")

    print(f"Done: {len(questions)} questions, IDs {START_ID}-{START_ID + COUNT - 1}")


if __name__ == "__main__":
    main()
