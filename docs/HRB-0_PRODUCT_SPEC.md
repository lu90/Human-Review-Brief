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
PR base SHA ──────────────┐
PR head SHA ──────────────┼──→ Fixed PR Scope
Spec / Tickets ───────────┘          │
                                    ▼
                         Repository Context Expansion
                      diff + dependency neighborhood
                       + relevant specs/tests/standards
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

HRB-0 uses **dynamic bounded context**, not a persisted repository baseline. The repository at the fixed base/head commits is the available context; the review expands outward from the PR diff only as needed.

## 5. PR Scope and Repository Context

The default HRB-0 review is a pre-merge pull-request review.

The fixed scope MUST identify:

- repository;
- base commit SHA;
- head commit SHA;
- PR or equivalent change-set identifier;
- originating spec / issue / ticket when available;
- relevant verification evidence.

HRB begins with the base→head diff and expands context only when necessary to interpret the change.

Context MAY include:

- directly affected modules and dependencies;
- callers/callees around changed boundaries;
- architecture and domain contracts;
- public APIs;
- persistence and external-system boundaries;
- relevant tests;
- repository standards;
- CI / build / deployment evidence;
- authoritative specifications and design documents.

A change SHOULD be interpreted against:

```text
base→head diff
+ dependency neighborhood
+ relevant spec/ticket
+ relevant tests and verification
+ repository standards/contracts
= bounded review context
```

HRB-0 MUST NOT require a persisted repository-understanding cache or invalidation engine. A future version MAY add persistent repository understanding if repeated context reconstruction is shown to be a real performance or cost bottleneck.

## 6. Evidence Model

Every material finding MUST be traceable to an **evidence chain** sufficient to support the claim.

An evidence chain is:

```text
Claim
  ↓
Evidence[1..n]
  ↓
Relation explaining how the evidence supports the claim
```

A finding MAY need one anchor or several. HRB MUST NOT force a multi-step claim into a single precise-looking permalink when the claim depends on change over time, omission, or comparison.

Supported evidence roles include:

- `spec_anchor` — requirement or intended behavior;
- `base_anchor` — relevant state before the change;
- `diff_anchor` — the actual added/removed/modified hunk;
- `head_anchor` — relevant state after the change;
- `test_anchor` — exact test or test result;
- `ci_anchor` — workflow run / job / step;
- `absence_evidence` — a documented search or inspection scope showing expected behavior/evidence was not found.

`absence_evidence` MUST record the inspected scope and MUST NOT claim exhaustive absence unless that scope is authoritative or demonstrably complete.

Example:

```text
Claim: authorization guard was removed

base_anchor  → guard exists before PR
diff_anchor  → PR deletes the guard
head_anchor  → affected path no longer performs the guard
```

Another example:

```text
Claim: required behavior is missing

spec_anchor      → requirement explicitly exists
head/diff anchors→ related implementation exists
absence_evidence → expected behavior/test not found in the relevant bounded scope
```

Each evidence item SHOULD use a stable source anchor whenever technically available.

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

## 6.1 Stable source anchors

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

## 9. Risk Dimensions

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

## 10. Human Review Brief Contract

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

## 11. Progressive Disclosure

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

## 12. Independent Agent Review Gate

Independent agent review is a first-class stage between evidence collection and attention triage.

For any material review, HRB MUST perform an independent review before generating the final Human Review Brief.

### 12.1 Isolation contract

The reviewer MUST NOT simply continue the implementation agent's full conversation.

The reviewer SHOULD receive a bounded review package containing:

- fixed point / base and review head;
- factual repository context expanded from the PR diff;
- originating spec / issue / tickets;
- the actual diff or changed artifacts;
- deterministic verification evidence;
- repository standards and relevant architectural contracts.

This reduces anchoring on the implementation agent's rationale.

If the runtime cannot create a separate sub-agent, HRB SHOULD use a fresh isolated context. If true isolation is unavailable, HRB MUST state that independent review was not achieved and MUST NOT present self-review as equivalent.

### 12.2 Reviewer objective

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

### 12.3 Required review axes

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

### 12.4 Review output

Independent reviewers produce evidence-backed findings, not merge decisions.

Each material finding SHOULD include:

- claim;
- why it may matter;
- primary evidence anchor;
- affected risk dimensions;
- unresolved question or counterexample.

The independent review feeds **Attention Triage**. It does not approve, reject, or merge the change.

HRB aggregates independent analyses to expose disagreement and uncertainty, not to manufacture consensus.

## 13. Human Gates

Human review should use explicit gates, not continuous reading.

A gate contains:

- what to inspect;
- why this is the right moment;
- 1–3 questions;
- direct evidence anchors;
- an actionable redirect if the answer is unsatisfactory;
- a stop rule when scope or risk has escaped the expected boundary.

## 14. Failure Modes to Prevent

HRB MUST guard against:

- reviewing the wrong diff or fixed point;
- incorrect or insufficient repository context;
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

## 15. Initial Modes

### `review`

Produce the bounded Human Review Brief for a fixed PR/change set using base→head scope and dynamically expanded repository context.

### `deep-review <item>`

Expand exactly one selected finding while preserving the original evidence chain.

## 16. Inspirations

HRB borrows several useful ideas while targeting a different problem:

- **pair-review** — human-in-the-loop review and deliberate human steering;
- **HUMAN.md proposal** — short, explicit human gates, actionable redirects, and stop rules;
- **Matt Pocock code-review** — fixed-point review and isolated review axes.

HRB adds repository understanding, attention triage, progressive disclosure, and evidence-linked human review as first-class concepts.

## 17. HRB-0 Exit Criteria

HRB-0 is complete when the project has agreed contracts for:

- PR-scoped bounded repository context;
- evidence-chain model and stable anchors;
- trust boundary and sensitive-evidence handling;
- attention taxonomy;
- Human Review Brief format;
- bootstrap / review / deep-review modes;
- human gates and stop rules;
- independent agent review and isolation contract;
- adversarial review requirements;
- deterministic handling of fixed points and source links.

Runtime implementation is intentionally deferred until these contracts are reviewed.
