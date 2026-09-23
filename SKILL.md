---
name: human-review-brief
description: "Compress a repository change set into a bounded, evidence-linked brief that tells a human what deserves attention, why, and where to inspect it. Use after implementation/review work when AI output is too large for efficient human review."
---

# Human Review Brief

Your job is not to summarize everything.

Your job is to decide **what deserves human attention** and preserve a direct path from each material claim to source evidence.

## Operating principles

1. Understand before triaging.
2. Pin the review scope before reading deeply.
3. Prefer evidence over narrative.
4. Separate machine verification from human judgment.
5. Do not spend human attention on deterministic noise.
6. Use progressive disclosure.
7. Never approve or merge on behalf of the human.

## Step 1 — Pin scope

Resolve and record:

- repository;
- fixed point / base;
- review head;
- commit range or PR;
- originating spec / issue / ticket when available;
- relevant CI / test evidence.

Fail early if the fixed point is invalid or the change set cannot be identified.

## Step 2 — Establish repository context

If no reliable repository baseline exists, perform a bootstrap scan.

Identify only the context needed to interpret the review:

- architecture;
- domains/modules;
- critical paths;
- contracts;
- persistence/external boundaries;
- standards;
- tests;
- CI;
- authoritative docs;
- generated / low-value areas.

On later runs, use **Baseline + Invalidation**: detect which repository-understanding sections are stale, refresh only those areas, and preserve unaffected context. Trigger a broader rebuild only when structural changes invalidate the existing model.

## Step 3 — Collect evidence

Collect evidence from the change set and surrounding context.

Important claims require stable anchors. For material findings, use stable source anchors whenever technically available. Prefer commit-pinned GitHub links with line ranges for repository code and other repository artifacts.

Anchor primary evidence, not another AI summary. A review report may be supporting context, but the evidence chain should terminate at source code, specs, tests, CI, migrations, issues, PRs, or other primary engineering artifacts.

If only local/uncommitted evidence exists, fall back to `path:line-range` and explicitly mark it as unstable/local.

Do not treat an implementation agent's explanation as evidence by itself.

## Step 4 — Run independent review axes when useful

Possible axes include:

- spec alignment;
- standards;
- architecture;
- correctness;
- tests and verification;
- security/privacy;
- data/migrations;
- operations.

Keep axes independent where possible so one reviewer's assumptions do not contaminate another.

## Step 5 — Attention triage

Classify relevant material:

- **A1 MUST REVIEW** — explicit human judgment required.
- **A2 SHOULD REVIEW** — material change worth human inspection.
- **A3 SKIM** — short context is enough.
- **A4 SAFE TO SKIP** — deterministic or low-value noise.

Justify attention using concrete dimensions such as correctness, architecture, security, data integrity, compatibility, blast radius, reversibility, novelty, scope alignment, and verification strength.

Do not rely on a single opaque score.

Treat the taxonomy as human-attention routing, not generic severity:

- A1–A4 answers: **How much human attention is required?**
- Risk dimensions answer: **Why?**

Do not mechanically map a numeric risk/confidence score to A1–A4. Strong deterministic verification may lower the attention required for some implementation details, but it must not erase judgment-heavy architecture, business-rule, security, data, or compatibility decisions.

## Step 6 — Produce the bounded brief

Default human-attention presentation budget:

- max 5 material changes;
- max 3 human decisions;
- show every A1;
- max 5 ungrouped A2 items;
- max 8 recommended deep reads.

**Budget the presentation, not the evidence.**

If the review exceeds these limits:

- never hide or group away A1 items;
- present the highest-attention A2 items individually;
- group remaining A2/A3 findings under an explicit overflow section with counts and evidence links;
- preserve the full evidence set for targeted deep review;
- never silently discard findings to satisfy the brief budget.

For every A1/A2 item provide:

1. what changed / what is uncertain;
2. why a human should care;
3. consequence if wrong;
4. direct evidence anchor;
5. the question the human needs to answer.

Use this format:

```markdown
# Human Review Brief

## Review scope

## What changed

## Decisions requiring human judgment

## MUST REVIEW

## SHOULD REVIEW

## Recommended deep reads

## Spec and scope drift

## Verification evidence

## Safe to skim

## Human decision
- [ ] Approve
- [ ] Request changes
- [ ] Deep review selected item
```

## Step 7 — Support deep review

If the human selects an item, expand only that item.

Bring in the exact surrounding source, relevant dependency context, competing evidence, tests, and trade-offs.

Do not regenerate the entire brief.

## Stop rules

Stop and surface the issue instead of compressing it away when:

- the fixed point is uncertain;
- source evidence conflicts materially;
- repository context is too stale to interpret the change;
- a destructive/data/security change lacks verification;
- the implementation materially exceeds the spec;
- an important claim has no traceable evidence;
- the requested review scope has expanded enough that a new brief is warranted.

## Output rule

A good HRB is not the most complete report.

A good HRB is the **smallest evidence-backed review surface that still lets a human make the important decisions**.
