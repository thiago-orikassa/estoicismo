#!/usr/bin/env python3
"""Finalize quote catalog by extracting literal snippets from canonical sources.

This script fills missing `quote_text` entries in content/catalog/quotes_catalog_90.csv,
normalizes canonical source URLs, and upgrades extraction status to pending_review.
It keeps rows already marked as verified unchanged.
"""

from __future__ import annotations

import csv
import html
import re
import time
import urllib.request
from pathlib import Path
from typing import Dict, List, Tuple

CATALOG_PATH = Path("content/catalog/quotes_catalog_90.csv")
USER_AGENT = "Mozilla/5.0 (Codex content sync; +https://openai.com)"

SENECA_BASE = "https://en.wikisource.org/wiki/Moral_letters_to_Lucilius/Letter_{n}"
EPICTETUS_URL = (
    "https://en.wikisource.org/wiki/"
    "The_Discourses_of_Epictetus%3B_with_the_Encheiridion_and_Fragments/"
    "The_Encheiridion_or_Manual"
)
MARCUS_BASE = (
    "https://en.wikisource.org/wiki/"
    "The_Thoughts_of_the_Emperor_Marcus_Aurelius_Antoninus/Book_{roman}"
)

ROMAN_BY_INT = {
    1: "I",
    2: "II",
    3: "III",
    4: "IV",
    5: "V",
    6: "VI",
    7: "VII",
    8: "VIII",
    9: "IX",
    10: "X",
    11: "XI",
    12: "XII",
}
INT_BY_ROMAN = {
    "I": 1,
    "II": 2,
    "III": 3,
    "IV": 4,
    "V": 5,
    "VI": 6,
    "VII": 7,
    "VIII": 8,
    "IX": 9,
    "X": 10,
    "XI": 11,
    "XII": 12,
    "XIII": 13,
    "XIV": 14,
    "XV": 15,
    "XVI": 16,
    "XVII": 17,
    "XVIII": 18,
    "XIX": 19,
    "XX": 20,
    "XXI": 21,
    "XXII": 22,
    "XXIII": 23,
    "XXIV": 24,
    "XXV": 25,
    "XXVI": 26,
    "XXVII": 27,
    "XXVIII": 28,
    "XXIX": 29,
    "XXX": 30,
    "XXXI": 31,
    "XXXII": 32,
    "XXXIII": 33,
    "XXXIV": 34,
    "XXXV": 35,
    "XXXVI": 36,
    "XXXVII": 37,
    "XXXVIII": 38,
    "XXXIX": 39,
    "XL": 40,
    "XLI": 41,
    "XLII": 42,
    "XLIII": 43,
    "XLIV": 44,
    "XLV": 45,
    "XLVI": 46,
    "XLVII": 47,
    "XLVIII": 48,
    "XLIX": 49,
    "L": 50,
}


def fetch_render_text(url: str) -> str:
    rendered = url + ("&action=render" if "?" in url else "?action=render")
    req = urllib.request.Request(rendered, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=45) as resp:
        return resp.read().decode("utf-8", "ignore")


def html_to_lines(raw_html: str) -> List[str]:
    text = re.sub(r"<style.*?</style>", " ", raw_html, flags=re.S | re.I)
    text = re.sub(r"<script.*?</script>", " ", text, flags=re.S | re.I)
    text = re.sub(r"<noscript.*?</noscript>", " ", text, flags=re.S | re.I)
    text = re.sub(r"<br\\s*/?>", "\n", text, flags=re.I)
    text = re.sub(r"<[^>]+>", " ", text)
    text = html.unescape(text)
    text = text.replace("\xa0", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n+", "\n", text)
    lines: List[str] = []
    for line in text.split("\n"):
        line = line.strip()
        if not line:
            continue
        if line.startswith("↑"):
            continue
        if line == "Footnotes":
            break
        lines.append(line)
    return lines


def normalize_text(text: str) -> str:
    text = text.strip()
    text = re.sub(r"^\d+\.\s*", "", text)
    text = re.sub(r"^\([^)]+\)\s*", "", text)
    text = re.sub(r"\[\s*\d+\s*\]", "", text)
    # Fix occasional spaced drop caps from OCR/transclusion output (e.g., "W E").
    text = re.sub(r"^([A-Z])\s+([A-Z])\b", r"\1\2", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip(" .") + "."


def first_sentence(text: str, min_chars: int = 60) -> str:
    parts = re.split(r"(?<=[.!?])\s+", text)
    parts = [p.strip() for p in parts if p.strip()]
    if not parts:
        return text.strip()

    chosen = parts[0]
    for idx in range(1, len(parts)):
        if len(chosen) >= min_chars:
            break
        chosen = f"{chosen} {parts[idx]}".strip()
    return chosen


def extract_seneca_quote(lines: List[str]) -> str:
    numbered = [ln for ln in lines if re.match(r"^\d+\.", ln)]
    if not numbered:
        raise ValueError("No numbered paragraph found for Seneca letter")
    preferred = next((ln for ln in numbered if ln.startswith("1.")), numbered[0])
    return first_sentence(normalize_text(preferred))


def build_epictetus_map(lines: List[str]) -> Dict[int, str]:
    out: Dict[int, str] = {}
    for idx, line in enumerate(lines):
        m = re.match(r"^([IVXLCDM]+)\.(?:\s*\[\s*\d+\s*\])?$", line)
        if not m:
            continue
        sec = INT_BY_ROMAN.get(m.group(1))
        if not sec:
            continue
        # Content is typically the immediate next non-roman line.
        content = ""
        for j in range(idx + 1, len(lines)):
            nxt = lines[j]
            if re.match(r"^([IVXLCDM]+)\.(?:\s*\[\s*\d+\s*\])?$", nxt):
                break
            if nxt == "Layout 1":
                continue
            if nxt.startswith("THE ENCHEIRIDION"):
                continue
            if nxt:
                content = nxt
                break
        if content:
            out[sec] = content
    return out


def build_marcus_map(lines: List[str], roman: str) -> Dict[int, str]:
    out: Dict[int, str] = {}

    # Section 1 appears as first narrative line after the roman heading.
    for idx, line in enumerate(lines):
        if line == f"{roman}.":
            for j in range(idx + 1, len(lines)):
                nxt = lines[j]
                if re.match(r"^\d+\.", nxt):
                    break
                if re.search(r"The Thoughts of the Emperor Marcus Aurelius Antoninus", nxt):
                    continue
                if nxt:
                    out[1] = nxt
                    break
            break

    for line in lines:
        m = re.match(r"^(\d+)\.\s*(.+)$", line)
        if not m:
            continue
        sec = int(m.group(1))
        out[sec] = m.group(0)

    return out


def parse_ref_book_section(ref: str) -> Tuple[int, int]:
    m = re.match(r"^Book\s+(\d+)\.(\d+)$", ref.strip())
    if not m:
        raise ValueError(f"Unsupported Marcus source_ref: {ref}")
    return int(m.group(1)), int(m.group(2))


def remap_marcus_ref(catalog_id: str, ref: str) -> Tuple[str, str]:
    """Remap invalid Book 2.18..2.30 refs to valid Book 3.1..3.13 refs."""
    if not catalog_id.startswith("MAR-"):
        return ref, ""
    idx = int(catalog_id.split("-")[1])
    if 18 <= idx <= 30 and ref.startswith("Book 2."):
        sec = idx - 17
        new_ref = f"Book 3.{sec}"
        note = f"source_ref ajustado de {ref} para {new_ref} (Book II em George Long encerra na secao 17)."
        return new_ref, note
    return ref, ""


def main() -> None:
    with CATALOG_PATH.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
        fieldnames = list(rows[0].keys()) if rows else []

    if not rows:
        raise SystemExit("Catalog is empty")

    # Cache source lines to avoid repeated downloads.
    line_cache: Dict[str, List[str]] = {}

    def get_lines(url: str) -> List[str]:
        if url not in line_cache:
            raw = fetch_render_text(url)
            line_cache[url] = html_to_lines(raw)
            time.sleep(0.12)
        return line_cache[url]

    # Preload shared documents.
    ep_lines = get_lines(EPICTETUS_URL)
    ep_map = build_epictetus_map(ep_lines)
    marcus_map_cache: Dict[int, Dict[int, str]] = {}

    updated = 0
    notes: List[str] = []

    for row in rows:
        status = row.get("status_verification", "").strip()
        if status == "verified" and row.get("quote_text", "").strip():
            # Keep validated records untouched.
            continue

        catalog_id = row["catalog_id"].strip()
        author = row["author"].strip()

        if author == "seneca":
            m = re.match(r"^Letter\s+(\d+)$", row["source_ref"].strip())
            if not m:
                raise ValueError(f"Invalid Seneca source_ref in {catalog_id}: {row['source_ref']}")
            letter = int(m.group(1))
            canonical_url = SENECA_BASE.format(n=letter)
            lines = get_lines(canonical_url)
            quote = extract_seneca_quote(lines)
            row["source_url"] = canonical_url
            row["quote_text"] = quote
            row["status_verification"] = "pending_review"
            updated += 1
            continue

        if author == "epictetus":
            m = re.match(r"^Section\s+(\d+)$", row["source_ref"].strip())
            if not m:
                raise ValueError(f"Invalid Epictetus source_ref in {catalog_id}: {row['source_ref']}")
            sec = int(m.group(1))
            content = ep_map.get(sec)
            if not content:
                raise ValueError(f"Section {sec} not found in Epictetus canonical source")
            quote = first_sentence(normalize_text(content))
            row["source_url"] = EPICTETUS_URL
            row["quote_text"] = quote
            row["status_verification"] = "pending_review"
            updated += 1
            continue

        if author == "marcus_aurelius":
            new_ref, note = remap_marcus_ref(catalog_id, row["source_ref"].strip())
            if note:
                notes.append(f"{catalog_id}: {note}")
                row["source_ref"] = new_ref

            book, sec = parse_ref_book_section(row["source_ref"].strip())
            if book not in ROMAN_BY_INT:
                raise ValueError(f"Unsupported Marcus book in {catalog_id}: Book {book}")
            roman = ROMAN_BY_INT[book]
            canonical_url = MARCUS_BASE.format(roman=roman)
            lines = get_lines(canonical_url)
            if book not in marcus_map_cache:
                marcus_map_cache[book] = build_marcus_map(lines, roman)
            content = marcus_map_cache[book].get(sec)
            if not content:
                raise ValueError(
                    f"Section {sec} not found in Marcus Book {book} for {catalog_id}"
                )
            quote = first_sentence(normalize_text(content))
            row["source_url"] = canonical_url
            row["quote_text"] = quote
            row["status_verification"] = "pending_review"
            updated += 1
            continue

        raise ValueError(f"Unknown author in {catalog_id}: {author}")

    with CATALOG_PATH.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"updated_rows={updated}")
    print(f"notes={len(notes)}")
    for note in notes:
        print(note)


if __name__ == "__main__":
    main()
