# HRB-0 Conformance Fixtures

These fixtures are canonical examples for validating Human Review Brief behavior.

They serve two purposes:

1. **Behavioral regression contract** — define invariants current and future implementations must preserve.
2. **Few-shot examples** — provide compact examples of expected review and attention-routing behavior when useful.

The current deterministic CI validates required contract artifacts, fixture structure, legal enum values, required canonical cases, critical behavioral invariants, Review Round Record structure/transition rules, and repository review-policy guardrails. It does not prove full natural-language semantic consistency or whether a live LLM's semantic judgment is correct.

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
- `C10_REMEDIATION_ROUND` — independent Fresh Review remains isolated from remediation verification; this fixture exercises the full route.
- `C11_ISOLATION_UNAVAILABLE` — isolation failure must be disclosed.
- `C12_HANDOFF_INPUT_ISOLATION` — Fresh Reviewer handoffs are canonical, whitelist-only, and deny prior-review/implementation context.
- `C13_POLICY_INTRODUCED_SAME_PR` — a review policy introduced by the current PR is evidence only and cannot authorize that same PR.
- `C14_DURABLE_REVIEW_STATE` — Review Round/Decision state is discoverable through marked PR comments without moving the reviewed head.
- `C15_PARTIAL_DECISION` — partial human decisions are recoverable but non-routable.
- `C16_DECISION_ROUTING` — valid Spec/Final decisions route deterministically.
- `C17_FINDING_CONTINUITY` — inherited Finding IDs remain linked across rounds even when Fresh Review finds nothing new.
- `C18_DECISION_SOURCE` — Agent inference cannot substitute for an explicit recoverable human statement.
- `C19_IMPLEMENTATION_REPORT_GATE` — Final HRB requires a current Implementation Report while Spec HRB does not.
- `C20_HEAD_INVALIDATION` — old-head approval cannot approve a new head, while proven descendant work can resume through route-specific durable progress, including Spec Loop and HRB-ready states.
- `C21_RECOVERY_IDEMPOTENCE` — restart recovery validates the whole Decision revision graph, payload bodies, and duplicate-write avoidance.
- `C22_AUTHORIZATION_BOUNDARY` — HRB approval does not grant merge/tracker/comment authorization.
- `C23_LEGACY_COMPATIBILITY` — legacy Round Records remain readable but cannot synthesize missing human approval.

The cases are defined in `cases.yaml`. Canonical Review Round Record examples are provided for both round 1 and round 2+, plus prior/partial/complete Review Decision Record examples. `review-payload-comments.example.yaml` contains actual marked PR-comment bodies for Raw Findings, Human Review Briefs, and remediation evidence.

`delta-review.example.yaml` supplies a full coverage baseline, a later delta basis and resolved primary-evidence facts for section 18.1. The validator exercises valid reuse, a chained delta, and rejection of missing coverage, stale heads, changed authority, broken lineage, unproven ancestry, invalid reuse and full-review escalation reasons. Existing full records remain compatible; these supplied-fact tests do not prove live semantic impact or runtime isolation.

Deterministic self-checks execute the recovery functions rather than only checking expected fixture booleans: they parse marked comment YAML; require non-null type-specific payload bodies; verify Raw Finding IDs against the Round Record; validate remediation payload correspondence; validate the entire Decision revision graph and reject hidden cycles; distinguish exact-head gate authority from descendant-head work continuation; resume implementation/remediation/Spec Loop work; route `ready_for_final_hrb` to Final HRB and `ready_for_spec_hrb` to Spec HRB; validate prior-Decision-driven carry-forward; reject omitted unresolved/remediation-required Findings; and reject foreign/non-owning `source_round_ref` values. They also retain the earlier transition, contradiction, stale-head, and legacy fail-closed checks.

`project-context.example.yaml` supplies optional context and a split-source input to those same functions. It adds executable checks for same-PR continuation/lineage, contract-set reordering, a changed entry locator, revision/addition/removal drift despite unchanged-scope flags, ready-state drift, verified legacy association, missing legacy baseline, attempted fixed-snapshot override, malformed/omitted context, project scope drift, new-PR provenance, and rejection of inherited IDs/approval/continuation across PRs. `split_source` is test input for an external ownership mapping, not an extra field on Round/Decision/Payload records. The old source ID is absent from the new PR's decision scope; the new PR uses its own Round 1. Schema-1 examples and C01–C23 remain unchanged.

Run the existing command `ruby scripts/validate_contracts.rb`. These deterministic checks validate structure and routing facts supplied to the functions; the Orchestrator must still verify recovered legacy snapshots against primary approved scope and sanitize indirect project/split inputs before a live Fresh Review. No live-Agent isolation or semantic judgment is inferred from this suite.


## Stage/version v2 extension

C01–C23 and all pre-existing schema-1 examples remain unchanged and exercise independent Spec / pinned legacy behavior. New cases C24–C29 and `final-review-v2.example.yaml`, `final-decision-v2.example.yaml`, `contract-transition-v2.example.yaml` exercise the lightweight Final branch and explicit switch. Fixtures are supplied facts and simulated Owner statements, never live approval.

The same Ruby command validates both versions. New Final Round records have no fresh-review, specialist coverage, testing or remediation-verification duty. The executable checks cover unknown-version rejection, stage mismatch, exact-head binding, actual marked brief-body recovery, real-source structure, partial decisions, whole revision-graph ambiguity, missing required evidence and owner routing, factual reuse, unresolved continuity and explicit-switch preservation. Actual evidence applicability, Owner identity, Git ancestry and effective authority still require source inspection by the Orchestrator.

Existing public `.github/workflows/hrb-contracts.yml` runs the validator on `pull_request` and main pushes using `ubuntu-latest` with `contents: read`. CI can provide the real Ruby result after publication. If Ruby is unavailable locally, report that gap; YAML/static checks are not a Ruby pass and do not prove live-agent behavior.
