#!/usr/bin/env python3
"""Build a full editorial seed from the catalog for review workflow.

Output file keeps already-verified entries as verified and marks extracted entries as probable.
"""

from __future__ import annotations

import csv
import json
from datetime import date
from pathlib import Path

CATALOG_PATH = Path("content/catalog/quotes_catalog_90.csv")
VERIFIED_SEED_PATH = Path("content/seeds/quotes_seed_verified_v1.json")
OUTPUT_PATH = Path("content/seeds/quotes_seed_review_v1.json")

SOURCE_EDITION_BY_AUTHOR = {
    "seneca": "Richard M. Gummere (Loeb Classical Library, 1918/1925), via Wikisource",
    "epictetus": "George Long (1877), The Discourses of Epictetus; with the Encheiridion and Fragments, via Wikisource",
    "marcus_aurelius": "George Long (1889), The Thoughts of the Emperor Marcus Aurelius Antoninus, via Wikisource",
}


def load_verified_metadata() -> dict:
    if not VERIFIED_SEED_PATH.exists():
        return {}
    data = json.loads(VERIFIED_SEED_PATH.read_text(encoding="utf-8"))
    out = {}
    for item in data.get("quotes", []):
        out[item.get("catalog_id")] = item
    return out


def main() -> None:
    verified = load_verified_metadata()

    rows = list(csv.DictReader(CATALOG_PATH.open("r", encoding="utf-8", newline="")))
    quotes = []
    for row in rows:
        catalog_id = row["catalog_id"]
        status = row["status_verification"]
        author = row["author"]

        base = {
            "catalog_id": catalog_id,
            "author": author,
            "quote_text": row["quote_text"],
            "source_work": row["source_work"],
            "source_ref": row["source_ref"],
            "source_url": row["source_url"],
            "source_edition": SOURCE_EDITION_BY_AUTHOR[author],
            "source_language": "en",
        }

        if status == "verified" and catalog_id in verified:
            item = {
                **base,
                "translation_edition": verified[catalog_id].get(
                    "translation_edition", "Tradução interna PT, Equipe Estoicismo (2026)"
                ),
                "translator": verified[catalog_id].get("translator", "Equipe Estoicismo"),
                "authenticity_level": "verified",
                "verification_status": "verified",
                "verification_notes": verified[catalog_id].get(
                    "verification_notes", "Verificado no lote SC-02 (2026-02-14)."
                ),
                "verified_by": verified[catalog_id].get("verified_by", "Stoic Content Curator"),
                "verified_at": verified[catalog_id].get("verified_at", "2026-02-14"),
            }
        else:
            item = {
                **base,
                "translation_edition": "N/A (texto canônico em inglês)",
                "translator": "N/A",
                "authenticity_level": "probable",
                "verification_status": "pending_review",
                "verification_notes": (
                    "Extração literal automatizada de fonte canônica; "
                    "revisão cruzada editorial pendente (SC-04)."
                ),
                "verified_by": "",
                "verified_at": "",
            }
        quotes.append(item)

    payload = {
        "generated_at": str(date.today()),
        "quotes": quotes,
    }
    OUTPUT_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"wrote={OUTPUT_PATH}")
    print(f"rows={len(quotes)}")


if __name__ == "__main__":
    main()
