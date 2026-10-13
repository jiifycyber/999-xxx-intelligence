# Production integration contracts

The prototype deliberately contains no direct device-control implementation.
Connect production services through authenticated adapters implementing these
conceptual contracts.

## Identity proof

Input: user ID, device ID, passkey assertion, optional biometric-success proof,
hardware-key attestation, requested purpose, timestamp, nonce.

Output: short-lived signed authority token containing explicit scope, expiry,
policy version, assurance level, and approval requirements.

## Device posture

Input: signed device identity, OS/version, encryption, patch state, security
controls, process summary, network summary, backup state, attestation time.

Output: posture decision, risk factors, remediation steps, and expiry.

## Response request

Input: incident ID, target asset, requested reversible action, authority token,
intent statement, policy version, idempotency key.

Output: accepted/denied/pending approval, execution receipt, rollback handle,
and audit-record identifier.

## Watchlist review

Input: authorized camera event, encrypted template candidate, liveness result,
confidence, lawful-purpose record, retention policy.

Output: possible match requiring human review. Never an autonomous identity
determination or punitive action.

## Evidence sealing

Input: incident ID, artifact hash, acquisition metadata, authorized collector,
retention class.

Output: immutable evidence receipt, integrity proof, and chain-of-custody entry.
