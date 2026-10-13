import json
from pathlib import Path
from datetime import datetime, timezone
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

root = Path("data/intelligence")
output = root / "fbi_live_test.json"

url = "https://api.fbi.gov/wanted/v1/list?page=1"

print("=== IC391DEA FBI LIVE API TEST ===")
print("ENDPOINT:", url)

try:
    request = Request(
        url,
        headers={
            "User-Agent": "IC391DEA-PublicDataResearch/1.0",
            "Accept": "application/json"
        }
    )

    with urlopen(request, timeout=25) as response:
        data = json.load(response)

    if not isinstance(data, dict):
        raise ValueError("Unexpected API response")

    items = data.get("items")

    if not isinstance(items, list):
        raise ValueError("Missing items array")

    result = {
        "source": "FBI Wanted API",
        "fetched_at": datetime.now(
            timezone.utc
        ).isoformat(),
        "reported_total": data.get("total"),
        "page": data.get("page"),
        "items": items
    }

    temp = output.with_suffix(".json.tmp")
    temp.write_text(
        json.dumps(result, indent=2),
        encoding="utf-8"
    )
    temp.replace(output)

    print("CONNECTION: SUCCESS")
    print("REPORTED TOTAL:", data.get("total"))
    print("PAGE RECORDS:", len(items))
    print("SAVED:", output)
    print("EXISTING DATABASE: UNCHANGED")

except (HTTPError, URLError, TimeoutError,
        ValueError, OSError) as e:
    print("CONNECTION: FAILED")
    print("ERROR:", str(e))
    print("EXISTING DATABASE: UNCHANGED")
