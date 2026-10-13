"""Read-only access to bundled IC391DEA FBI intelligence."""

import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]

DATASETS = {
    "all_records": "data/fbi/fbi_wanted_records.json",
    "child_review": "data/fbi/child_related_candidates.json",
}


def dataset_status():
    result = {}

    for name, relative_path in DATASETS.items():
        path = PROJECT_ROOT / relative_path

        if not path.is_file():
            result[name] = {
                "available": False,
                "record_count": 0,
            }
            continue

        data = json.loads(path.read_text())
        records = data.get("records", [])

        result[name] = {
            "available": isinstance(records, list),
            "record_count": len(records) if isinstance(records, list) else 0,
            "retrieved_at": data.get("retrieved_at"),
        }

    return result


def search_records(query, limit=10):
    query = query.strip().lower()

    if not query:
        return []

    path = PROJECT_ROOT / DATASETS["all_records"]
    data = json.loads(path.read_text())

    results = []

    for record in data.get("records", []):
        if not isinstance(record, dict):
            continue

        searchable = " ".join(
            str(record.get(field, ""))
            for field in (
                "title",
                "description",
                "details",
                "subjects",
                "uid",
            )
        ).lower()

        if query in searchable:
            results.append(record)

        if len(results) >= max(1, min(limit, 20)):
            break

    return results
