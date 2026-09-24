# Human Review Brief

Human Review Brief (HRB) is a human-attention layer for AI-assisted software development.

AI can generate code, specifications, tickets, tests, and review reports faster than a human can read them. HRB does not try to replace review with a filter. Its job is to organize all review findings by attention priority, preserve traceability to source evidence, and compile them into a review surface a human can actually work through.

## Core idea

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

For round 2+, HRB keeps the fresh independent `base → current head` review and adds a separate `previous review head → current head` remediation verification. A small Review Round Record preserves the factual handoff between rounds without feeding old conclusions into the fresh Reviewer.

Raw Findings use stable IDs such as `R5-RF-01`: the sequence restarts each round, the round prefix keeps IDs unambiguous across the PR review lifecycle, and remediation always references the original prior-round ID unchanged.

Worker prompts are not rewritten from scratch each round. HRB uses canonical role-specific handoff templates under `handoffs/`; the Orchestrator fills only declared inputs. Fresh-review handoffs are deny-by-default and exclude prior findings, remediation conclusions, previous human decisions, author rationale, and the implementation conversation.

Every PR first passes through the same independent specialist review dimensions. There is no up-front "material" or "mechanical" gate. The Reviewer returns Raw Findings; a separate Brief Compiler then orders every finding by **human-attention value**, explains the relevant risk dimensions, and generates a compact Markdown review surface with evidence chains and deep links such as:

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

## Status

The repository is in the initial design stage. The first milestone is to define PR-scoped context construction, attention taxonomy, evidence chains, trust boundaries, and the contract for a bounded Human Review Brief.
