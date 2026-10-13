#!/bin/bash

PROJECT="/Users/jontariuscooper/Downloads/999_XXX"
PYTHON="/opt/homebrew/bin/python3"

SENSOR="$PROJECT/endpoint_sensor/level6_mac_sensor.py"
STATE="$PROJECT/endpoint_sensor/state/health_status.json"
LOG="$PROJECT/endpoint_sensor/logs/level6_endpoint.log"
ERR="$PROJECT/endpoint_sensor/logs/level6_endpoint_error.log"

mkdir -p "$(dirname "$STATE")" "$(dirname "$LOG")"

STARTED="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

"$PYTHON" "$SENSOR" >>"$LOG" 2>>"$ERR"
RC=$?

FINISHED="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

"/opt/homebrew/bin/python3" - "$STATE" "$RC" "$STARTED" "$FINISHED" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
rc = int(sys.argv[2])
started = sys.argv[3]
finished = sys.argv[4]

try:
    state = json.loads(path.read_text()) if path.exists() else {}
except Exception:
    state = {}

state["last_attempt_at"] = finished
state["last_exit_code"] = rc
state["last_run_started_at"] = started

if rc == 0:
    state["last_success_at"] = finished
    state["sensor_state"] = "HEALTHY"
else:
    state["sensor_state"] = "DEGRADED"

path.write_text(json.dumps(state, indent=2))
PY

exit "$RC"
