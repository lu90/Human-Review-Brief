# HRB-0 Conformance Fixtures

These fixtures are canonical examples for validating Human Review Brief behavior.

They serve two purposes:

1. **Conformance / regression tests** — verify that future implementations still obey the HRB contracts.
2. **Few-shot examples** — provide compact examples of expected review and attention-routing behavior when useful.

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

The cases are defined in `cases.yaml`.
