# Human Review Brief

Human Review Brief (HRB) is a human-attention layer for AI-assisted software development.

AI can generate code, specifications, tickets, tests, and review reports faster than a human can read them. HRB does not try to replace review with a filter. Its job is to organize all review findings by attention priority, preserve traceability to source evidence, and compile them into a review surface a human can actually work through.

## Stage and version

New Final work uses `hrb-final-v2` only after that contract is approved and effective: existing report + implementation/verification/Code Review evidence → chat brief → real Owner Decision → durable same-head PR-comment read-back. Final HRB adds no independent specialist audit, tests or remediation verification. Missing applicable evidence returns to its owner.

Dedicated eight-dimension Final coverage is removed, including Operations / Observability, Performance / Compatibility and Adversarial Challenge; it is not transferred to Code Review and no equivalent coverage is claimed. Independent Spec review remains under `hrb-v1`. Historical and in-flight v1 work keeps its fixed contract; explicit switches retain unresolved Findings, evidence and permissions. Unknown versions fail closed. See [version selection](docs/HRB-0_PRODUCT_SPEC.md#32-select-the-effective-contract-before-execution) and [v2 records](docs/HRB-0_PRODUCT_SPEC.md#21-lightweight-final-contract-v2).

The model below describes independent Spec and pinned legacy v1 execution only. WORKFLOW-EVOLUTION-B's own review remains pinned to its pre-B contract; the proposed simplification cannot approve itself.

## Core idea (Spec and legacy v1)

```text
Main Agent / Orchestrator
          │
          ├── Reviewer
          │     ├── Fresh Review mode → Raw Findings
          │     └── Remediation Review mode → prior-finding status
          │
          └── Brief Compiler
                Raw Findings → A1–A4 ordering
                → complete Human Review Brief
                         │
                         ▼
                    Human Decision
```

The Reviewer and Brief Compiler are separate primary roles with separate contexts. The Reviewer has two execution modes: Fresh Review and, for round 2+, Remediation Review. Remediation Review is not a fourth primary role. The Reviewer optimizes for finding/evidencing problems or verifying remediation; the Brief Compiler optimizes for routing human attention without dropping important findings.

Repositories may define a short, human-owned `.hrb/REVIEW_POLICY.md` for project-specific review rules. During a PR review, the base-SHA version governs; a policy change in the PR cannot authorize itself.

### Principles

1. **Understand before summarizing.**
   Build enough repository context around the fixed PR scope before judging individual artifacts.

2. **Order and organize, do not silently filter.**
   Every finding stays represented; the brief compresses evidence and partitions large review surfaces instead of hiding findings.

3. **Evidence over confidence.**
   Every important claim should link back to source code, documentation, tests, issues, PRs, or CI evidence.

4. **Humans own decisions.**
   AI may classify, challenge, and explain. Architectural choices, risk acceptance, and merge decisions remain explicit human decisions.

5. **Bound human attention.**
   A normal review brief should be reviewable in roughly 5–15 minutes. Deep dives are opt-in.

6. **Progressive disclosure.**
   Start with the smallest useful brief. Every important item should provide a path to deeper evidence.

## Proposed review model

HRB-0 is **PR-centered**.

The default review moment is before a pull request is merged. The fixed review scope is the PR's base commit → head commit. The repository is available as context, but HRB expands outward from the diff only as needed: affected dependencies, relevant specifications, tests, standards, and CI evidence.

HRB-0 intentionally does **not** require a persisted repository-understanding cache or an invalidation engine. A later version may add one if repeated context reconstruction becomes a demonstrated bottleneck.

Round 1 requires a full independent `base → current head` review. Later rounds may independently review `previous review head → current head` plus affected dependencies/contracts when fixed authority, ancestry and complete prior coverage are verified. Missing evidence, changed authority or broad/high-risk/uncertain impact requires full review. New and reused coverage are explicit for every dimension; old conclusions stay out of the Fresh Reviewer context. Separate remediation still verifies prior Findings, and each new head still requires its applicable human Decision. Product Spec section 18.1 defines the bounded additive record contract. Round and Decision records use discoverable GitHub PR comments without changing the reviewed head.

Raw Findings use stable IDs such as `R5-RF-01`: the sequence restarts each round, the round prefix keeps IDs unambiguous across the PR review lifecycle, and remediation always references the original prior-round ID unchanged.

Worker prompts are not rewritten from scratch each round. HRB uses canonical role-specific handoff templates under `handoffs/`; the Orchestrator fills only declared inputs. Fresh-review handoffs are deny-by-default and exclude prior findings, remediation conclusions, previous human decisions, author rationale, the implementation conversation, and the full Implementation Report. Final-review compilation may use the current Implementation Report after the Orchestrator verifies it is current.

Every Spec or pinned legacy v1 PR entering HRB first passes through the same independent specialist review dimensions. There is no up-front "material" or "mechanical" gate. The Reviewer returns Raw Findings; a separate Brief Compiler then orders every finding by **human-attention value**, explains the relevant risk dimensions, and generates a compact Markdown review surface with evidence chains and deep links such as:

```text
src/orders/service.py#L120-L168
docs/architecture.md#runtime-boundary
PR #123
CI run #456
```

## Initial brief shape

```markdown
# Human Review Brief

## 1. Review scope and execution
Pinned scope, Reviewer/Compiler isolation, and specialist coverage.

## 2. Remediation verification
For round 2+, whether prior findings were actually addressed.

## 3. What changed
Up to 5 notable changes.

## 4. Decisions requiring human judgment
Up to 3 explicit decisions.

## 5. Findings by attention
All findings ordered A1 Highest → A4 Low. Large finding sets are partitioned by topic/module/risk cluster instead of being omitted.

## 6. Recommended deep reads
A small set of exact files / line ranges / document sections, each with
a reason why human attention is warranted.

## 7. Spec and scope drift
Missing requirements, changed assumptions, scope creep, and undocumented
decisions.

## 8. Verification evidence
Tests, type checks, lint, CI, migrations, runtime validation, and gaps.

## 9. Finding coverage
Which Raw Findings are represented in this brief or partition, including deduplication mappings.

## 10. Human decision
- [ ] Approve
- [ ] Request changes
- [ ] Deep review selected item
```

## Contract authority

When documents disagree:

1. `docs/HRB-0_PRODUCT_SPEC.md` defines the product contract.
2. `SKILL.md` defines the agent execution contract and MUST conform to the Product Spec.
3. `HUMAN.md` defines the human review protocol and MUST conform to the Product Spec.
4. `README.md` is an overview only and is not normative.

## Durable review state

PR-centered HRB uses marked GitHub PR comments for Review Round Records and Review Decision Records. Stable `hrb://github/...` record references plus explicit `supersedes_ref` chains make recovery deterministic; timestamps are not workflow state. Missing or invalid human decisions fail closed instead of being inferred from discussion.

A valid Decision Record can route a fresh Orchestrator to continued Human Review, the Implementation Remediation Loop, the Spec Loop, tickets/authorized implementation after Spec approval, or closeout after Final approval. Those routes preserve their own external-write authorization gates.

Existing project entries can link Phase/ChangeSet, authoritative scope, fixed shared-contract revisions, progress/report, and durable review records without copying approval state. Optional schema-1 `project_context` snapshots use the contract in Product Spec section 5.1. Linked continuation compares contract pins and blocks drift even when scope is asserted unchanged. Older records remain readable; missing reviewed pins are recovered from approved primary scope or reported as a gap.

An in-progress delivery can keep its existing PR lineage. Splitting into new PRs preserves old Findings as provenance and obtains new applicable decisions. The Orchestrator strips review history and author arguments from project/split entries before supplying current facts through the existing Fresh Review allowlist. Small tasks use their applicable route; project association alone does not require HRB.

## Status

The repository is in the initial design stage. The current contracts cover PR-scoped context construction, attention taxonomy, evidence chains, trust boundaries, durable review state, and the bounded Human Review Brief.
