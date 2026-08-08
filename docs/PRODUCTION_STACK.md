# Recommended production stack

Keep the app provider-neutral. Use adapters so vendors can be changed without rebuilding the product.

- Database/Auth: Supabase/Postgres
- Video storage/transcoding/CDN: approved commercial video infrastructure with signed URLs, adaptive HLS/DASH and content protection
- Search: Postgres FTS/trigram initially; dedicated search engine at scale
- Recommendations: event pipeline + ranking service using watch history, favorites, recency, creator affinity and moderation-safe signals
- Verification: reputable 18+/identity verification provider appropriate to operating jurisdictions
- Payments: payment processor that expressly underwrites the business category
- Observability: structured logs, uptime monitoring, error tracking and audit logs
- Security: RLS, least privilege, signed upload/playback URLs, secrets only server-side, malware scanning, rate limiting
