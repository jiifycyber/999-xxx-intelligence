# V3 Markeela AI Setup

## What is already in the app
- Markeela AI navigation item
- Ask Markeela full chat interface
- Discovery mode
- Creator Assistant mode
- Admin AI mode
- Local/offline guidance fallback
- Secure Supabase Edge Function adapter
- Tool/action proposal architecture
- AI model reporting in responses

## Deploy the Edge Function
From the project root:

```bash
supabase functions deploy markeela-agent
```

## Connect it to 999 Intelligence
Set the secrets in your existing Supabase project:

```bash
supabase secrets set NINE99_INTELLIGENCE_GATEWAY_URL="YOUR_999_INTELLIGENCE_GATEWAY_ENDPOINT"
supabase secrets set NINE99_INTELLIGENCE_GATEWAY_KEY="YOUR_PRIVATE_GATEWAY_KEY"
```

Do not put AI-provider API keys directly in Flutter or GitHub Pages.

## Permission model
Markeela may:
- read approved catalog/search data
- summarize creator/submission state
- recommend next actions
- assist with forms/workflows
- summarize analytics and queues

Markeela must not autonomously:
- approve age/identity verification
- approve performer consent
- approve commercial licensing
- publish content
- execute takedowns
- issue payouts
- change privileged roles

Those operations remain explicit server-side authorized actions.

## To become fully live
1. Deploy Supabase migrations from V1/V2.
2. Deploy `markeela-agent`.
3. Deploy/configure your 999 Intelligence gateway.
4. Give the gateway a frontier AI provider/model.
5. Add server-side tool adapters for catalog search, creator state, reports and analytics.
6. Test each tool with role/permission enforcement.
