# Genesis architecture

## Six operating planes

1. Authority - identity, biometrics, roles, command signing, and approvals.
2. Visibility - endpoint, network, cloud, camera, application, and AI telemetry.
3. Intelligence - correlation, threat hunting, attack paths, and risk scoring.
4. Enforcement - reversible containment through authorized adapters.
5. Recovery - immutable backup verification and rehearsed restoration.
6. Governance - signed policies, audit evidence, privacy, and human oversight.

## Production services

- `identity-service`: passkeys, hardware-key attestations, short-lived sessions.
- `device-service`: enrollment, posture, inventory, health, and ownership proof.
- `telemetry-gateway`: authenticated, schema-validated event ingestion.
- `detection-engine`: correlation, behavioral rules, and attack-graph updates.
- `policy-engine`: versioned policies, simulation, signing, and enforcement.
- `incident-service`: evidence timelines, cases, approvals, and response state.
- `response-orchestrator`: narrowly scoped, reversible response adapters.
- `evidence-vault`: encrypted, append-only evidence with retention controls.
- `recovery-service`: backup health, integrity proofs, RTO/RPO, restore drills.
- `camera-gateway`: authorized camera events and human-reviewed watchlists.

## Safety invariants

- Never treat possession of a credential as proof of human intent.
- Never store raw Face ID or Touch ID biometric data.
- Never allow facial recognition to take punitive action autonomously.
- Never execute destructive operations from the UI without server-side policy.
- Never accept unsigned endpoint telemetry or unsigned policy updates.
- Preserve human approval, auditability, revocation, and recovery.
- Keep demonstration data unmistakably separate from production telemetry.

## Standards target

- NIST Cybersecurity Framework 2.0
- NIST SP 800-207 Zero Trust Architecture
- NIST SP 800-53 control mapping
- NIST Secure Software Development Framework
- CISA Zero Trust Maturity Model
- MITRE ATT&CK detection coverage
