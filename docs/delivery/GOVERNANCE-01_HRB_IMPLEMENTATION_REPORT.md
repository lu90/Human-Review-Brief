# GOVERNANCE-01 HRB implementation report

Date: 2026-10-03. This report records the bounded HRB implementation slice; it does not assert Final HRB readiness or create an approval.

## Scope and source

- Approved scope: [Canonical Spec](https://github.com/lu90/matt-workflow-guidelines/blob/42f1feb9fa93c45f0d847024468a2cfdc25a37a0/docs/delivery/GOVERNANCE-01_CANDIDATE_SPEC.md) and [Owner Proposal](https://github.com/lu90/matt-workflow-guidelines/blob/42f1feb9fa93c45f0d847024468a2cfdc25a37a0/docs/delivery/GOVERNANCE-01_OWNER_PROPOSAL.md), fixed main-source SHA `42f1feb9fa93c45f0d847024468a2cfdc25a37a0`.
- The main Orchestrator supplied its verified implementation authorization from [PR 3 Owner Decision](https://github.com/lu90/matt-workflow-guidelines/pull/3#issuecomment-5966513122). This worker did not perform Owner approval or independent review.
- Local source: `lu90/Human-Review-Brief`, base `7caef3543fa526d04efd426c570778425a63f3ea`, branch `feat/governance-project-context`. The main Orchestrator must fix the actual implementation commit for integration and review.
- Shared Tracker: [engineering entry](../agents/issue-tracker.md), canonical main ledger, slice `GOV-01-4`. No separate HRB ticket state was created.

## Implemented behavior

| Files | Change and reason |
| --- | --- |
| `docs/HRB-0_PRODUCT_SPEC.md` | Sections 5.1/5.2 define project linkage, optional fixed shared-contract snapshots, legacy recovery, split provenance, and sanitization; section 18.2 connects these to existing continuation checks |
| `SKILL.md`, `HUMAN.md`, `README.md` | Connect existing entries to Phase/ChangeSet/scope/progress/Round/Decision without duplicating approval; retain small-task routes and all gates after entering HRB |
| `handoffs/fresh-review.md` | Reuse existing allowlist slots for current authoritative Spec/decision-table/shared-contract facts; sanitize project/split/semantic-check indirect inputs and exclude old Findings, Owner decisions, author arguments, and the full report |
| `handoffs/remediation-review.md`, `handoffs/brief-compiler.md` | Keep same-PR lineage and distinguish old split IDs as external provenance |
| `scripts/validate_contracts.rb` | Add optional context shape checks and fixed pin-set comparison inside the existing continuation functions; retain original decision, payload, lineage, and C01–C23 checks |
| `fixtures/hrb-0/project-context.example.yaml`, fixture README | Supply actual inputs for the existing Ruby continuation/lineage self-checks, including drift and cross-PR rejection |
| `docs/agents/issue-tracker.md` | Link the main-owned Tracker and fixed approved scope; no local ticket database or new approval state |

The optional mapping has exactly `entry_ref`, `phase_id`, `changeset_id`, `scope_ref`, and `shared_contracts: [{ref, revision}]`; each revision is a full lowercase 40-character Git SHA. Existing schema-1 Round/Decision/Payload fixtures remain unchanged. No-context records retain their original call behavior.

For linked continuation, the current shared-contract set must equal the reviewed set, independent of ordering. Additions, removals, and revision drift block all resumable routes and ready states despite unchanged-scope flags. Changing only the entry locator does not change authorized scope. Old Rounds can adopt linkage using optional `recovered_project_context`, verified from that source Decision's primary approved scope; the input cannot override an existing Round snapshot. Without the reviewed baseline, the function reports a recovery gap.

New PRs start their own review lineage. The split-origin fixture preserves the source PR/Round/Finding outside the destination Round's inherited and decision sets; existing lineage/Decision/progress functions reject cross-PR inheritance and old approval reuse.

## Checks performed and remaining validation

Static checks performed locally:

- `git diff --check` passed.
- Python YAML parsing of fixtures and handoff front matter passed; schema versions and C01–C23 identifiers remain unchanged. This is structural parsing, not a Ruby behavior replacement.
- Compared original canonical YAML fixtures, `.hrb/REVIEW_POLICY.md`, and the CI workflow with the base: byte-identical. Handoff front matter/allowlists are unchanged. Original Ruby executable self-check block remains intact; new checks are appended.
- Confirmed the permitted branch/base and inspected the complete original Ruby validator, fixtures, CI, Product Spec, execution/human docs, and handoffs. No ancestor `AGENTS.md` or `CLAUDE.md` exists in this workspace hierarchy.

Attempted `ruby scripts/validate_contracts.rb` returned exit 127: `ruby: command not found`. Ruby syntax/runtime and the deterministic behavioral self-checks were **not executed locally**. The existing GitHub workflow still runs that exact command, without dependency changes; the main Orchestrator must run it against the fixed integrated source.

The added Ruby checks call actual existing functions for linked same-PR continuation/lineage; old-head gate rejection; contract reordering/locator update; revision/addition/removal drift; ready-state drift; legacy baseline recovery/missing baseline; attempted baseline override; optional context shape/identity drift; independent new-PR Round 1; and old-PR inheritance/approval/continuation rejection. They contain no new `expected: true` substitute for behavior.

Code Review/remediation: this worker performed a local implementation self-check only. Independent Code Review and any resulting remediation belong to the main Orchestrator's remaining delivery work. Live-Agent tests of input sanitization, route selection, and isolation were not run by this worker. No refactor or public runtime replacement was performed; the original Ruby contracts remain the regression boundary.

## Integration interface and limits

Use the same context keys in main project/ChangeSet templates. On continuation, read current authoritative contract revisions into existing progress. For a legacy Round, supply the optional sixth argument to `continuation_errors` / `continuation_route` only after verifying the recovered snapshot's source against the Decision's fixed approved scope. Primary-evidence verification remains an orchestration obligation, just as proof of Git ancestry is supplied to the existing functions; this deterministic helper does not fetch or authenticate remote artifacts.

The main Tracker/ticket links point to sibling maintained sources and need a fixed main-source revision in a standalone export. Integrate this HRB commit separately from the aggregate/main commits and verify the final combined artifacts. This worker wrote only this repository and made no remote write, PR, merge, release, cache replacement, or skill reload.

Known remaining limits are the unexecuted Ruby regression, pending independent review/integrated validation, and live-Agent semantic/isolation behavior. A project status label or this report cannot satisfy any of those checks.
