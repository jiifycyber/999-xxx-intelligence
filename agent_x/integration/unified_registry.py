"""Agent X unified IC391DEA intelligence registry."""

from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]

MODULES = {
    "command_center": {
        "source": "lib/screens/war_room_screen.dart",
        "mode": "read_only",
    },
    "active_cases": {
        "source": "lib/services/ic391_case_store.dart",
        "mode": "read_only",
    },
    "missing_children": {
        "source": "lib/screens/missing_children_screen.dart",
        "mode": "read_only",
    },
    "fbi_intelligence": {
        "source": "lib/services/fbi_intelligence_service.dart",
        "mode": "read_only",
    },
    "security_events": {
        "source": "lib/services/level6_event_service.dart",
        "mode": "read_only",
    },
    "device_security": {
        "source": "lib/services/cipher_backend_service.dart",
        "mode": "read_only",
    },
    "evidence": {
        "source": "lib/widgets/ic391_module_workspace.dart",
        "mode": "read_only",
    },
    "cameras": {
        "source": "lib/widgets/camera_vault_panel.dart",
        "mode": "read_only",
    },
    "legal_intelligence": {
        "source": "agent_x/knowledge/legal/blacks_law/lookup.py",
        "mode": "read_only",
    },
    "personal_memory": {
        "source": "agent_x/memory/memory_service.py",
        "mode": "read_only",
    },
}


def system_registry():
    results = {}

    for name, config in MODULES.items():
        path = PROJECT_ROOT / config["source"]

        results[name] = {
            "source": config["source"],
            "source_exists": path.is_file(),
            "access_mode": config["mode"],
            "connected": False,
        }

    return results
