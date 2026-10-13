
import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).with_name("agent_x_memory.sqlite3")

def connect():
    db = sqlite3.connect(DB_PATH, timeout=10)
    db.row_factory = sqlite3.Row
    return db

def save_message(user_id, role, content):
    if role not in ("user", "assistant"):
        raise ValueError("Invalid message role")
    if not user_id or not content.strip():
        raise ValueError("User ID and content required")
    with connect() as db:
        db.execute(
            "INSERT INTO conversations (user_id,role,content) VALUES (?,?,?)",
            (user_id, role, content)
        )

def recent_messages(user_id, limit=12):
    limit = max(1, min(int(limit), 20))
    with connect() as db:
        rows = db.execute(
            """SELECT role,content FROM conversations
               WHERE user_id=?
               ORDER BY id DESC LIMIT ?""",
            (user_id, limit)
        ).fetchall()
    return [
        {"role": row["role"], "content": row["content"]}
        for row in reversed(rows)
    ]

def save_personal_memory(user_id, category, content):
    if not user_id or not category or not content.strip():
        raise ValueError("Memory fields required")
    with connect() as db:
        db.execute(
            """INSERT INTO personal_memories
               (user_id,category,content) VALUES (?,?,?)""",
            (user_id, category, content)
        )

def get_personal_memories(user_id):
    with connect() as db:
        rows = db.execute(
            """SELECT id,category,content,created_at
               FROM personal_memories
               WHERE user_id=? ORDER BY id DESC""",
            (user_id,)
        ).fetchall()
    return [dict(row) for row in rows]


def search_history(user_id, query, limit=10):
    if not user_id or not isinstance(query, str) or not query.strip():
        return []
    limit = max(1, min(int(limit), 20))
    words = [w for w in query.split() if len(w) >= 3][:8]
    if not words:
        return []
    conditions = " OR ".join("instr(lower(content), lower(?)) > 0" for _ in words)
    sql = "SELECT id, role, content, created_at FROM conversations WHERE user_id=? AND (" + conditions + ") ORDER BY id DESC LIMIT ?"
    with connect() as db:
        rows = db.execute(sql, [user_id] + words + [limit]).fetchall()
    return [dict(row) for row in rows]
