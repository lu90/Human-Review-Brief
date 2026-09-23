# Human Review Brief

Human Review Brief (HRB) is a human-attention layer for AI-assisted software development.

AI can generate code, specifications, tickets, tests, and review reports faster than a human can read them. HRB does not try to summarize everything. Its job is to decide what deserves human attention, preserve traceability to the source evidence, and produce a bounded review brief that a human can actually review.

## Core idea

```text
PR / base→head diff / Spec / Tests / CI
                ↓
      Repository Context Expansion
                ↓
         Evidence Collection
                ↓
      Independent Specialist Review
                ↓
        Attention Triage
                ↓
       Human Review Brief
                ↓
          Human Decision
```

### Principles

1. **Understand before summarizing.**
   Build enough repository context around the fixed PR scope before judging individual artifacts.

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

HRB-0 is **PR-centered**.

The default review moment is before a pull request is merged. The fixed review scope is the PR's base commit → head commit. The repository is available as context, but HRB expands outward from the diff only as needed: affected dependencies, relevant specifications, tests, standards, and CI evidence.

HRB-0 intentionally does **not** require a persisted repository-understanding cache or an invalidation engine. A later version may add one if repeated context reconstruction becomes a demonstrated bottleneck.

Every PR first passes through the same independent specialist review dimensions. There is no up-front "material" or "mechanical" gate. Only after review does HRB classify findings by **human-attention value**, explain the relevant risk dimensions, and generate a compact Markdown brief with evidence chains and deep links such as:

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
Up to 5 notable changes.

## 2. Decisions requiring human judgment
Up to 3 explicit decisions.

## 3. MUST REVIEW / SHOULD REVIEW
A1 findings requiring human judgment and the highest-value A2 findings.

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

## Contract authority

When documents disagree:

1. `docs/HRB-0_PRODUCT_SPEC.md` defines the product contract.
2. `SKILL.md` defines the agent execution contract and MUST conform to the Product Spec.
3. `HUMAN.md` defines the human review protocol and MUST conform to the Product Spec.
4. `README.md` is an overview only and is not normative.

## Status

The repository is in the initial design stage. The first milestone is to define PR-scoped context construction, attention taxonomy, evidence chains, trust boundaries, and the contract for a bounded Human Review Brief.
