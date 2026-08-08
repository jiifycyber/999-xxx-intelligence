# 999XXX Platform V3 — Markeela AI Edition

999XXX V3 adds Agent Markeela as the AI operating layer across the platform.

## Markeela capabilities
- Consumer conversational assistant
- Catalog/search assistance
- Personalized discovery recommendations
- Creator onboarding guidance
- Rights/consent checklist guidance
- Moderation queue summaries
- Report/takedown triage assistance
- Admin analytics summaries
- Platform help and navigation
- Tool-aware action planning

## Important safety/permission boundaries
Markeela does NOT autonomously:
- approve identity or age verification
- approve performer consent
- approve commercial rights
- publish content
- execute takedowns
- make payouts
- change privileged roles

Those actions remain behind explicit authorized workflows.

## AI architecture
999XXX App
→ Markeela Agent
→ secure Supabase Edge Function
→ 999 Intelligence Gateway / configured frontier AI provider
→ approved 999XXX tools + Supabase data
→ response/action proposal back to app

External AI credentials are never stored in Flutter.
