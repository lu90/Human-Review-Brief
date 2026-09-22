# Human Review Brief

Human Review Brief (HRB) is a human-attention layer for AI-assisted software development.

AI can generate code, specifications, tickets, tests, and review reports faster than a human can read them. HRB does not try to summarize everything. Its job is to decide what deserves human attention, preserve traceability to the source evidence, and produce a bounded review brief that a human can actually review.

## Core idea

```text
Repository / PR / Spec / Tickets / CI
                ↓
      Repository Understanding
                ↓
         Evidence Collection
                ↓
        Attention Triage
                ↓
       Human Review Brief
                ↓
          Human Decision
```

### Principles

1. **Understand before summarizing.**
   Build a repository-level mental model before judging individual artifacts.

2. **Triage, do not dump.**
   The output is intentionally smaller than the available evidence.

3. **Evidence over confidence.**
   Every important claim should link back to source code, documentation, tests, issues, PRs, or CI evidence.

4. **Humans own decisions.**
   AI may classify, challenge, and explain. Architectural choices, risk acceptance, and merge decisions remain explicit human decisions.

5. **Bound human attention.**
   A normal review brief should be reviewable in roughly 5–15 minutes. Deep dives are opt-in.

6. **Progressive disclosure.**
   Start with the smallest useful brief. Every important item should provide a path to deeper evidence.

## Proposed review model

HRB will support two layers of repository understanding:

- **Bootstrap scan** — inspect the repository broadly and build a baseline understanding of architecture, domains, important artifacts, conventions, tests, and risk boundaries.
- **Incremental review** — refresh only what changed, then relate those changes back to the baseline model.

The review pipeline will classify findings by both **risk** and **human-attention value**, then generate a compact Markdown brief with deep links such as:

```text
src/orders/service.py#L120-L168
docs/architecture.md#runtime-boundary
PR #123
CI run #456
```

## Initial brief shape

```markdown
# Human Review Brief

## 1. What changed
Up to 5 material changes.

## 2. Decisions requiring human judgment
Up to 3 explicit decisions.

## 3. High-risk findings
Only findings that can materially affect correctness, architecture,
security, data, compatibility, or operations.

## 4. Recommended deep reads
A small set of exact files / line ranges / document sections, each with
a reason why human attention is warranted.

## 5. Spec and scope drift
Missing requirements, changed assumptions, scope creep, and undocumented
decisions.

## 6. Verification evidence
Tests, type checks, lint, CI, migrations, runtime validation, and gaps.

## 7. Safe to skim
Mechanical, generated, boilerplate, or otherwise low-attention changes.

## 8. Human decision
- [ ] Approve
- [ ] Request changes
- [ ] Deep review selected item
```

## Status

The repository is in the initial design stage. The first milestone is to define the repository-understanding model, attention taxonomy, evidence/link format, and the contract for a bounded Human Review Brief.
