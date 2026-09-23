# HRB-0 Conformance Fixtures

These fixtures are canonical examples for validating Human Review Brief behavior.

They serve two purposes:

1. **Behavioral regression contract** — define invariants current and future implementations must preserve.
2. **Few-shot examples** — provide compact examples of expected review and attention-routing behavior when useful.

The current deterministic CI validates fixture structure, legal enum values, required canonical cases, critical behavioral invariants for the canonical cases, the minimum Review Round Record contract, and the repository review-policy guardrails. It does not yet prove live LLM semantic behavior.

## Golden expectations

The fixtures intentionally do **not** require exact natural-language output.

LLM wording is non-deterministic, so each case defines behavioral invariants instead:

- required specialist-review behavior;
- required evidence-chain roles;
- expected attention class;
- required human-facing behavior;
- forbidden behavior.

An implementation conforms when it preserves these invariants, even if wording or formatting differs.

## Initial cases

- `C01_FORMATTING_ONLY` — formatting-only change.
- `C02_PUBLIC_API_BREAK` — breaking public API change.
- `C03_AUTH_GUARD_REMOVED` — authorization guard removed.
- `C04_LOCAL_REFACTOR_VERIFIED` — local refactor with deterministic verification.
- `C05_LARGE_MIGRATION_MANY_A1` — oversized migration review with many A1 findings.
- `C06_REPOSITORY_PROMPT_INJECTION` — repository content attempts to control reviewer behavior.
- `C07_REVIEW_COVERAGE_MANIFEST` — all specialist dimensions must be explicitly accounted for.
- `C08_POLICY_CHANGE_SAME_PR` — proposed policy cannot authorize itself.
- `C09_REDACTED_EVIDENCE` — sensitive payload is removed while provenance survives.
- `C10_REMEDIATION_ROUND` — fresh full review remains isolated from remediation verification.
- `C11_ISOLATION_UNAVAILABLE` — isolation failure must be disclosed.

The cases are defined in `cases.yaml`. A Review Round Record example is provided separately.
