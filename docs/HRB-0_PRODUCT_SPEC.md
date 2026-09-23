# HRB-0 — Product Specification

## 1. Problem

AI-assisted development can produce specifications, tickets, code, tests, migrations, CI output, and review reports faster than a human can inspect them.

The bottleneck is no longer generation. It is **human review bandwidth**.

Human Review Brief (HRB) exists to answer one question:

> Given all available engineering evidence, what deserves human attention now?

HRB is not a generic summarizer and not a replacement for code review. It is an **attention-triage and progressive-disclosure layer** between machine-generated engineering output and human judgment.

## 2. Goals

HRB MUST:

- build enough repository understanding to interpret a change in context;
- classify information by human-attention value and engineering risk;
- compress large engineering outputs into a bounded brief;
- preserve traceability from every material claim to source evidence;
- provide direct deep links to exact code lines, document sections, PRs, issues, tests, or CI evidence;
- tell the human what to inspect, why it matters, and what decision is required;
- allow deeper review without forcing the human to read everything.

## 3. Non-goals

HRB is not intended to:

- autonomously approve or merge changes;
- replace tests, static analysis, security scanners, or specialist code review;
- summarize every file or every document;
- hide uncertainty behind a single confidence score;
- rebuild a full semantic index from scratch on every review.

## 4. Core workflow

```text
              FIRST RUN
Repository ───────────────→ Repository Understanding Baseline
                                  │
                                  │
                                  ▼
Spec / Tickets / PR / Diff / Tests / CI / Docs
                                  │
                                  ▼
                         Evidence Collection
                                  │
                                  ▼
                    Independent Agent Review
                     ├─ Spec / scope alignment
                     ├─ Architecture / correctness
                     ├─ Tests / verification
                     └─ Adversarial challenge
                                  │
                                  ▼
                         Attention Triage
                                  │
                                  ▼
                         Human Review Brief
                                  │
                                  ▼
                           Human Decision
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
                 Approve                  Deep Review
                                                │
                                                ▼
                                      Source Evidence
```

Subsequent runs SHOULD use **Baseline + Invalidation**: reuse the repository-understanding baseline by default, explicitly detect which parts have become stale, and refresh only invalidated areas. Structural changes MAY trigger a partial or full rebuild.

## 5. Repository Understanding

HRB needs an "understand anything" style repository model, but only to the depth required for review.

The baseline SHOULD identify:

- repository purpose;
- major domains and modules;
- architecture and dependency boundaries;
- runtime entry points;
- critical business paths;
- public APIs and contracts;
- persistence and external-system boundaries;
- repository standards and conventions;
- test topology;
- CI / build / deployment paths;
- authoritative specifications and design documents;
- generated / vendored / low-value areas;
- known high-risk areas.

The baseline is context, not the final review output.

### 5.1 Bootstrap mode

The first review performs a broad repository scan and creates a baseline map.

### 5.2 Incremental mode

Later reviews determine what changed, identify which parts of the baseline are invalidated, and update only affected context.

Typical invalidation triggers include:

- module or directory restructuring;
- dependency or runtime changes;
- schema or migration changes;
- public API or contract changes;
- changes to architecture or authoritative design documents;
- changes that cross domain, persistence, security, or external-system boundaries.

Minor documentation, formatting, or local implementation changes SHOULD NOT force unrelated baseline sections to refresh.

A change SHOULD be interpreted against:

```text
changed artifact
+ affected dependency/domain context
+ originating spec/ticket
+ verification evidence
+ repository standards
= review context
```

## 6. Evidence Model

Every material finding MUST be traceable to evidence.

An evidence anchor SHOULD be one of:

- immutable GitHub code permalink at a commit SHA with line range;
- document permalink plus heading or line range;
- PR / issue / discussion reference;
- commit reference;
- test file and exact test;
- CI workflow run / job / step;
- migration or schema artifact;
- generated report with stable path.

Preferred code anchor:

```text
https://github.com/<owner>/<repo>/blob/<commit>/<path>#L120-L168
```

Branch-only links SHOULD be avoided for review evidence when a commit SHA is available because line numbers can drift.

For material findings, stable source anchors are REQUIRED whenever technically available. Repository artifacts SHOULD default to commit-pinned permalinks. Evidence anchors MUST point to primary source evidence rather than merely to another AI-generated summary or review report.

Preferred anchor forms:

- code: commit SHA + file + line range;
- Markdown/spec: commit SHA + file + heading or line range;
- PR/issue/discussion: stable item reference;
- CI: workflow run + job, and step when needed;
- tests: commit SHA + test file + test name or line range;
- schema/migration: commit SHA + artifact + line range.

When only local or otherwise unstable evidence is available, HRB MAY fall back to a path-and-line reference such as `src/service.ts:120-168`, but it MUST label that anchor as unstable/local rather than presenting it as a permanent link.

## 7. Attention Triage

HRB classifies by **human attention**, not merely severity.

### A1 — MUST REVIEW

Human judgment is required before proceeding.

Typical triggers:

- architecture boundary changes;
- irreversible or costly decisions;
- security / privacy / authorization behavior;
- data loss, schema, migration, or destructive behavior;
- public API / compatibility changes;
- material business-rule changes;
- unverified assumptions affecting correctness;
- spec deviation that changes intended behavior;
- risk acceptance.

### A2 — SHOULD REVIEW

Material engineering change where human understanding is valuable but no immediate hard gate is known.

Typical triggers:

- complex control flow;
- concurrency or state-machine changes;
- new dependency or integration boundary;
- meaningful error-handling behavior;
- substantial refactor of a critical path;
- test strategy changes;
- operational or observability changes.

### A3 — SKIM

Useful context that can normally be understood from a short summary.

Examples:

- straightforward implementation details;
- local refactors with strong test coverage;
- documentation updates describing already-reviewed behavior.

### A4 — SAFE TO SKIP

Normally no human reading required unless another finding points here.

Examples:

- generated files;
- lockfile churn without dependency-policy concern;
- formatting-only changes;
- mechanical renames;
- boilerplate;
- changes fully enforced by deterministic tooling.

## 8. Risk Dimensions

Attention level SHOULD be justified using explicit dimensions rather than a mysterious aggregate score:

- correctness;
- architecture;
- security/privacy;
- data integrity;
- compatibility;
- operational reliability;
- scope/spec alignment;
- reversibility;
- novelty;
- blast radius;
- verification strength.

The explanation matters more than the label.

The A1–A4 taxonomy answers **how much human attention is required**. Risk dimensions answer **why that attention is required**. HRB MUST NOT derive attention levels from a single opaque severity or confidence score. Deterministic verification may reduce required human attention when it genuinely removes uncertainty, but it does not automatically eliminate attention for architecture, business-rule, security, data, or other judgment-heavy changes.

## 9. Human Review Brief Contract

A normal brief SHOULD be reviewable in approximately 5–15 minutes.

Default presentation budgets:

- material changes: max 5;
- human decisions: max 3;
- A1 findings: show all;
- A2 findings: max 5 before grouping;
- recommended deep reads: max 8;
- each deep read MUST explain why the human should open it.

These are presentation budgets, not evidence-loss limits.

**Budget the presentation, not the evidence.**

When a category exceeds its default budget, HRB SHOULD:

- show all A1 items without compression or omission;
- show the highest-attention A2 items individually;
- group additional A2/A3 material under an explicit overflow section with counts and drill-down links;
- preserve all collected evidence for deep review;
- state clearly that additional findings exist rather than silently dropping them.

Required structure:

```markdown
# Human Review Brief

## Review scope
Fixed point, head, spec/ticket sources, verification sources.

## What changed
Up to 5 material changes.

## Decisions requiring human judgment
Up to 3 questions with evidence and consequence.

## MUST REVIEW
All A1 items.

## SHOULD REVIEW
Highest-value A2 items.

## Recommended deep reads
Exact source anchors + why each deserves attention.

## Spec and scope drift
Missing requirement / partial implementation / scope creep /
changed assumption / undocumented decision.

## Verification evidence
What was verified and what remains unverified.

## Safe to skim
Grouped A3/A4 material.

## Human decision
- [ ] Approve
- [ ] Request changes
- [ ] Deep review selected item
```

## 10. Progressive Disclosure

The brief MUST NOT contain all collected evidence.

Instead:

```text
Brief statement
    ↓
Why it matters
    ↓
Evidence anchor
    ↓
Optional deep review
    ↓
Full source context
```

The human should be able to move from 30 seconds of orientation to a targeted code/document deep dive without losing traceability.

## 11. Independent Agent Review Gate

Independent agent review is a first-class stage between evidence collection and attention triage.

For any material review, HRB MUST perform an independent review before generating the final Human Review Brief.

### 11.1 Isolation contract

The reviewer MUST NOT simply continue the implementation agent's full conversation.

The reviewer SHOULD receive a bounded review package containing:

- fixed point / base and review head;
- relevant repository-understanding baseline;
- originating spec / issue / tickets;
- the actual diff or changed artifacts;
- deterministic verification evidence;
- repository standards and relevant architectural contracts.

This reduces anchoring on the implementation agent's rationale.

If the runtime cannot create a separate sub-agent, HRB SHOULD use a fresh isolated context. If true isolation is unavailable, HRB MUST state that independent review was not achieved and MUST NOT present self-review as equivalent.

### 11.2 Reviewer objective

The reviewer's job is not to validate the author's story.

The reviewer MUST actively try to disconfirm it by looking for:

- missing or partially implemented requirements;
- incorrect assumptions;
- scope creep;
- architecture boundary violations;
- correctness defects and edge cases;
- over-engineering or speculative abstractions;
- weak or misleading tests;
- verification gaps;
- security, data, compatibility, or operational risks;
- plausible alternative designs that expose hidden trade-offs.

### 11.3 Required review axes

A material review MUST cover at least:

- spec / scope alignment;
- architecture / correctness;
- tests / verification;
- adversarial challenge.

Additional specialist axes MAY be added when relevant:

- repository standards;
- security / privacy;
- data / migrations;
- operations / observability;
- performance;
- compatibility.

Skipped axes MUST be recorded with a reason.

### 11.4 Review output

Independent reviewers produce evidence-backed findings, not merge decisions.

Each material finding SHOULD include:

- claim;
- why it may matter;
- primary evidence anchor;
- affected risk dimensions;
- unresolved question or counterexample.

The independent review feeds **Attention Triage**. It does not approve, reject, or merge the change.

HRB aggregates independent analyses to expose disagreement and uncertainty, not to manufacture consensus.

## 12. Human Gates

Human review should use explicit gates, not continuous reading.

A gate contains:

- what to inspect;
- why this is the right moment;
- 1–3 questions;
- direct evidence anchors;
- an actionable redirect if the answer is unsatisfactory;
- a stop rule when scope or risk has escaped the expected boundary.

## 13. Failure Modes to Prevent

HRB MUST guard against:

- reviewing the wrong diff or fixed point;
- stale repository understanding;
- summaries without evidence;
- important details buried by verbosity;
- AI self-certification presented as verification;
- "all tests passed" used as proof of business correctness;
- generated noise receiving equal attention to architecture decisions;
- unstable line links;
- false certainty when evidence is incomplete;
- a reviewer rubber-stamping another agent's narrative;
- the implementation agent being treated as its own independent reviewer;
- adversarial review being skipped without disclosure.

## 14. Initial Modes

### `bootstrap`

Build or refresh repository understanding.

### `review`

Produce the bounded Human Review Brief for a fixed change set.

### `deep-review <item>`

Expand exactly one selected finding while preserving the original evidence chain.

## 15. Inspirations

HRB borrows several useful ideas while targeting a different problem:

- **pair-review** — human-in-the-loop review and deliberate human steering;
- **HUMAN.md proposal** — short, explicit human gates, actionable redirects, and stop rules;
- **Matt Pocock code-review** — fixed-point review and isolated review axes.

HRB adds repository understanding, attention triage, progressive disclosure, and evidence-linked human review as first-class concepts.

## 16. HRB-0 Exit Criteria

HRB-0 is complete when the project has agreed contracts for:

- repository-understanding baseline;
- evidence anchors;
- attention taxonomy;
- Human Review Brief format;
- bootstrap / review / deep-review modes;
- human gates and stop rules;
- independent agent review and isolation contract;
- adversarial review requirements;
- deterministic handling of fixed points and source links.

Runtime implementation is intentionally deferred until these contracts are reviewed.
