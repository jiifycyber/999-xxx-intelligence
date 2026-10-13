"""Read-only IC391DEA intelligence gateway."""

from unified_registry import system_registry
from fbi_connector import dataset_status


def intelligence_status():
    modules = system_registry()

    for item in modules.values():
        item["connected"] = False
        item["connection_note"] = (
            "Source registered; runtime data access not implemented"
        )

    try:
        fbi = dataset_status()
        available = any(
            info.get("available", False)
            for info in fbi.values()
            if isinstance(info, dict)
        )

        modules["fbi_intelligence"]["connected"] = available
        modules["fbi_intelligence"]["connection_note"] = (
            "Local public FBI snapshot only; not live FBI access"
        )
    except Exception as exc:
        fbi = {
            "error": type(exc).__name__,
        }

    return {
        "gateway_version": 1,
        "access_mode": "read_only",
        "modules": modules,
        "fbi_datasets": fbi,
        "limitations": [
            "Source files do not establish live runtime data access",
            "Flutter SharedPreferences cases are not connected",
            "Supabase security events are not connected",
            "No autonomous monitoring or mission execution yet",
        ],
    }
