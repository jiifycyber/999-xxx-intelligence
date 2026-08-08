# Setup

1. Create/configure a Supabase project.
2. Review `supabase/migrations/001_999xxx_core.sql` with your backend/security engineer before applying.
3. Add Row Level Security policies appropriate to customer, creator, moderator and administrator roles.
4. Integrate a reputable identity/age verification provider.
5. Integrate secure video object storage, malware scanning, transcoding and CDN.
6. Integrate an adult-compatible payment processor only after underwriting/approval.
7. Have counsel finalize the agreements in `/legal` and determine all applicable recordkeeping/age-assurance requirements.
8. Build Flutter from `/app`.

Do not place government-ID images or payment secrets in public storage or the Flutter client.
Do not enable publishing solely because a file upload succeeded. Publishing must be rights/consent/verification gated.
