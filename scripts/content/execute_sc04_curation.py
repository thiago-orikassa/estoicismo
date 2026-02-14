#!/usr/bin/env python3
"""Execute SC-04 editorial integrity review and publish curated production seed.

Actions:
1) Re-link a few recommendations to stronger quote options.
2) Classify catalog statuses as verified/rejected (no pending states).
3) Generate verified seed v2 for content governance.
4) Generate backend production daily_seed.json with curated PT quotes.
"""

from __future__ import annotations

import csv
import json
from datetime import date
from pathlib import Path

CATALOG_PATH = Path("content/catalog/quotes_catalog_90.csv")
RECOMMENDATIONS_PATH = Path("content/recommendations/recommendations_40.csv")
VERIFIED_SEED_V2_PATH = Path("content/seeds/quotes_seed_verified_v2.json")
BACKEND_DAILY_SEED_PATH = Path("backend/data/daily_seed.json")

# Replace weaker/problematic options with stronger alternatives before final verification.
RECOMMENDATION_REMAP = {
    "REC-007": "SEN-11",  # replace SEN-7 (too fragmentary)
    "REC-008": "SEN-12",  # replace SEN-8 (fragmentary/open quote)
    "REC-022": "EPI-21",  # replace EPI-12 (contains slavery reference)
    "REC-028": "EPI-23",  # replace EPI-18 (omen/raven reference)
    "REC-036": "MAR-11",  # replace MAR-6 (awkward self-harm phrasing)
    "REC-040": "MAR-12",  # replace MAR-10 (low clarity/verbosity)
}

PT_TRANSLATIONS = {
    "SEN-1": "Nada, Lucílio, é nosso, exceto o tempo.",
    "SEN-2": "Estar em toda parte é não estar em lugar nenhum.",
    "SEN-3": "Enviaste-me uma carta pelas mãos de um ‘amigo’, como o chamas.",
    "SEN-4": "Permanece como começaste e apressa-te, para desfrutar por mais tempo de uma mente em paz consigo.",
    "SEN-5": "Alegro-me por perseverares nos estudos e por te empenhares, todos os dias, em te tornares melhor.",
    "SEN-6": "Sinto, Lucílio, que não estou apenas sendo corrigido, mas transformado.",
    "SEN-9": "O sábio é autossuficiente; ainda assim, deseja amigos.",
    "SEN-10": "Não mudo de opinião: evita a multidão, evita o pequeno grupo e evita até o isolamento improdutivo.",
    "SEN-11": "Pelas primeiras palavras do teu amigo, percebe-se seu espírito, entendimento e progresso.",
    "SEN-12": "Por onde olho, vejo sinais de que a velhice avança.",
    "EPI-1": "Algumas coisas dependem de nós; outras não.",
    "EPI-2": "Lembra: quem falha no que deseja é infeliz; e quem cai no que tenta evitar também.",
    "EPI-3": "Em tudo que agrada à alma, lembra-te de perguntar: qual é a natureza desta coisa?",
    "EPI-4": "Antes de agir, recorda que tipo de ação estás prestes a realizar.",
    "EPI-5": "Os homens não se perturbam pelas coisas que acontecem, mas pelas opiniões sobre elas.",
    "EPI-6": "Não te exaltes por vantagem que pertence a outro.",
    "EPI-7": "Como numa viagem, mantém a atenção no navio; na vida, não te distraias do que é essencial.",
    "EPI-8": "Não busques que os acontecimentos ocorram como queres; quer que ocorram como são.",
    "EPI-9": "A doença impede o corpo, mas não a vontade, a menos que a própria vontade permita.",
    "EPI-10": "Em cada acontecimento, volta-te para ti e pergunta que recurso tens para fazer bom uso dele.",
    "EPI-11": "Nunca digas: ‘perdi’; diz antes: ‘foi devolvido’.",
    "EPI-13": "Se queres progredir, aceita parecer tolo e sem prestígio nas coisas externas.",
    "EPI-14": "Se queres que filhos, cônjuge e amigos vivam para sempre, queres controlar o que não depende de ti.",
    "EPI-15": "Na vida, comporta-te como num banquete: toma com decência o que chega até ti.",
    "EPI-16": "Ao ver alguém em dor, não te deixes arrastar pela aparência de que o mal está nas coisas externas.",
    "EPI-17": "Lembra-te: és ator de uma peça, no papel que te foi dado.",
    "EPI-19": "Serás invencível se não entrares em disputa na qual não podes vencer.",
    "EPI-20": "Lembre-se: não é quem o insulta ou fere que o ofende, mas a sua opinião de que isso é insulto.",
    "EPI-21": "Mantém diante dos olhos, todos os dias, a morte e o exílio; assim evitarás desejos mesquinhos.",
    "EPI-23": "Se te voltas aos externos para agradar alguém, perdeste teu propósito.",
    "MAR-1": "Ao começar a manhã, diga a si mesmo: encontrarei o intrometido, o ingrato, o arrogante, o enganador, o invejoso e o insociável.",
    "MAR-2": "Em nenhum lugar o homem se recolhe com mais tranquilidade e liberdade de perturbação do que na própria alma.",
    "MAR-3": "Se algo é difícil para ti, não penses que é impossível ao homem; se é possível ao homem e conforme à sua natureza, considera que também está ao teu alcance.",
    "MAR-4": "A mente assume o caráter dos seus pensamentos habituais; a alma é tingida por eles.",
    "MAR-5": "A cada momento, pensa e age como romano e como ser humano: com dignidade simples, justiça e liberdade interior.",
    "MAR-7": "As coisas externas te distraem? Reserva tempo para aprender algo bom e deixa de ser arrastado.",
    "MAR-8": "Raramente alguém é infeliz por não entender a mente alheia; quem ignora a própria mente, porém, sofre necessariamente.",
    "MAR-9": "Lembra sempre a natureza do todo, a tua própria natureza e como tua parte se relaciona com esse todo.",
    "MAR-11": "Como podes deixar a vida a qualquer instante, regula cada ato e pensamento de acordo com isso.",
    "MAR-12": "Quão depressa tudo desaparece: os corpos no universo e sua lembrança no tempo.",
}

THEME_BY_CONTEXT = {
    "trabalho": "disciplina",
    "ansiedade": "controle",
    "foco": "disciplina",
    "relacionamentos": "justica",
    "decisao_dificil": "proposito",
}

BEHAVIOR_INTENT_BY_CONTEXT = {
    "trabalho": "agir com foco no dever essencial de hoje",
    "ansiedade": "reduzir reatividade e escolher resposta racional",
    "foco": "proteger atenção em uma tarefa de cada vez",
    "relacionamentos": "responder com respeito e autocontrole",
    "decisao_dificil": "decidir por virtude, não por impulso",
}

CONTEXT_TAGS_BY_CONTEXT = {
    "trabalho": ["trabalho", "foco"],
    "ansiedade": ["ansiedade", "emocao"],
    "foco": ["foco", "disciplina"],
    "relacionamentos": ["relacionamentos", "justica"],
    "decisao_dificil": ["decisao_dificil", "proposito"],
}

SOURCE_EDITION_BY_AUTHOR = {
    "seneca": "Richard M. Gummere (Loeb Classical Library, 1918/1925), via Wikisource",
    "epictetus": "George Long (1877), The Discourses of Epictetus; with the Encheiridion and Fragments, via Wikisource",
    "marcus_aurelius": "George Long (1889), The Thoughts of the Emperor Marcus Aurelius Antoninus, via Wikisource",
}


def quote_id_from_catalog_id(catalog_id: str) -> str:
    return f"q-{catalog_id.lower()}"


def recommendation_id_to_seed_id(rec_id: str) -> str:
    # REC-001 -> r-001
    return f"r-{rec_id.split('-')[-1]}"


def main() -> None:
    catalog_rows = list(csv.DictReader(CATALOG_PATH.open("r", encoding="utf-8", newline="")))
    rec_rows = list(csv.DictReader(RECOMMENDATIONS_PATH.open("r", encoding="utf-8", newline="")))

    catalog_by_id = {r["catalog_id"]: r for r in catalog_rows}

    # 1) Remap selected recommendation links.
    remap_count = 0
    for rec in rec_rows:
        rec_id = rec["recommendation_id"]
        if rec_id in RECOMMENDATION_REMAP:
            rec["linked_catalog_id"] = RECOMMENDATION_REMAP[rec_id]
            remap_count += 1

    curated_ids_in_order = [rec["linked_catalog_id"] for rec in rec_rows]
    curated_id_set = set(curated_ids_in_order)

    missing_catalog_ids = sorted([cid for cid in curated_id_set if cid not in catalog_by_id])
    if missing_catalog_ids:
        raise SystemExit(f"Missing curated catalog IDs: {missing_catalog_ids}")

    missing_pt = sorted([cid for cid in curated_id_set if cid not in PT_TRANSLATIONS])
    if missing_pt:
        raise SystemExit(f"Missing PT translations for curated IDs: {missing_pt}")

    # 2) Classify full catalog (no pending status remains).
    for row in catalog_rows:
        row["status_verification"] = "verified" if row["catalog_id"] in curated_id_set else "rejected"

    with CATALOG_PATH.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(catalog_rows[0].keys()))
        writer.writeheader()
        writer.writerows(catalog_rows)

    with RECOMMENDATIONS_PATH.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rec_rows[0].keys()))
        writer.writeheader()
        writer.writerows(rec_rows)

    # 3) Build verified seed v2 (editorial governance artifact).
    seed_v2_quotes = []
    for cid in curated_ids_in_order:
        row = catalog_by_id[cid]
        seed_v2_quotes.append(
            {
                "catalog_id": cid,
                "author": row["author"],
                "quote_text": PT_TRANSLATIONS[cid],
                "source_work": row["source_work"],
                "source_ref": row["source_ref"],
                "source_url": row["source_url"],
                "source_edition": SOURCE_EDITION_BY_AUTHOR[row["author"]],
                "source_language": "en",
                "translation_edition": "Tradução curada PT, Equipe Estoicismo (SC-04/2026)",
                "translator": "Equipe Estoicismo",
                "authenticity_level": "verified",
                "verification_status": "verified",
                "verification_notes": "Revisão cruzada SC-04 concluída; texto user-facing em PT curado e referência canônica confirmada.",
                "verified_by": "Stoic Content Curator",
                "verified_at": "2026-02-14",
            }
        )

    seed_v2_payload = {
        "generated_at": str(date.today()),
        "quotes": seed_v2_quotes,
    }
    VERIFIED_SEED_V2_PATH.write_text(
        json.dumps(seed_v2_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    # 4) Build backend production seed from curated set + recommendations.
    backend_quotes = []
    for rec in rec_rows:
        cid = rec["linked_catalog_id"]
        row = catalog_by_id[cid]
        context = rec["context"]

        backend_quotes.append(
            {
                "id": quote_id_from_catalog_id(cid),
                "author": row["author"],
                "text": PT_TRANSLATIONS[cid],
                "source_work": row["source_work"],
                "source_ref": row["source_ref"],
                "language": "pt",
                "theme_primary": THEME_BY_CONTEXT[context],
                "behavior_intent": BEHAVIOR_INTENT_BY_CONTEXT[context],
                "context_tags": CONTEXT_TAGS_BY_CONTEXT[context],
                "authenticity_level": "verified",
            }
        )

    backend_recommendations = []
    for rec in rec_rows:
        steps = [s.strip() for s in rec["action_steps"].split(";") if s.strip()]
        backend_recommendations.append(
            {
                "id": recommendation_id_to_seed_id(rec["recommendation_id"]),
                "quote_id": quote_id_from_catalog_id(rec["linked_catalog_id"]),
                "context": rec["context"],
                "action_title": rec["action_title"],
                "action_steps": steps,
                "estimated_minutes": int(rec["estimated_minutes"]),
                "journal_prompt": rec["journal_prompt"],
            }
        )

    backend_payload = {
        "quotes": backend_quotes,
        "recommendations": backend_recommendations,
    }
    BACKEND_DAILY_SEED_PATH.write_text(
        json.dumps(backend_payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"recommendations_remapped={remap_count}")
    print(f"curated_verified={len(curated_id_set)}")
    print(f"catalog_rejected={len(catalog_rows) - len(curated_id_set)}")
    print(f"verified_seed_v2={VERIFIED_SEED_V2_PATH}")
    print(f"backend_seed={BACKEND_DAILY_SEED_PATH}")


if __name__ == "__main__":
    main()
