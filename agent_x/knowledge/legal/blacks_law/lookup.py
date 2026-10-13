import sqlite3
import sys

db = "agent_x/knowledge/legal/blacks_law/blacks_law.db"

term = " ".join(sys.argv[1:]).strip()
if not term:
    print("Usage: python3 lookup.py <legal term>")
    raise SystemExit

con = sqlite3.connect(db)

query = '"' + term.replace('"', '') + '"'

rows = con.execute(
    """SELECT rowid, content
       FROM chunks
       WHERE chunks MATCH ?
       ORDER BY bm25(chunks)
       LIMIT 5""",
    (query,)
).fetchall()

print(f"=== BLACK'S LAW: {term.upper()} ===")

if not rows:
    print("No matching entry found.")
else:
    for rowid, content in rows:
        print(f"\n--- MATCH {rowid} ---")
        print(content[:2200])

con.close()
