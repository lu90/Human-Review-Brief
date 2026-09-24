# HUMAN.md — Human Review Protocol

This file is for the human using Human Review Brief.

Do not read the whole repository because HRB produced a brief. Start with the brief and expand only where the evidence justifies it.

## Gate 1 — Scope sanity check (~1 minute)

Read only **Review scope**.

Ask:

- Is this the right base / fixed point?
- Is this the right branch, PR, or commit range?
- Is the correct spec / ticket being used?
- Is the brief centered on the actual base→current-head PR diff rather than an outdated repository summary?
- If this is round 2+, are the previous review head and round number recorded?
- If `.hrb/REVIEW_POLICY.md` changed in this PR, is the base-SHA policy still being used for the current review?

If not, redirect:

> Stop. Rebuild the brief against the correct review scope.

## Gate 2 — Human decisions (~2–5 minutes)

First read **Review execution**. Confirm that:

- every required specialist dimension is explicitly recorded as reviewed with findings or reviewed with no finding;
- Reviewer isolation status and method are reported;
- Brief Compiler isolation status and method are reported.

An omitted dimension is not equivalent to `no finding`.

If this is round 2+, also confirm that the fresh full review ran before the separate remediation verification.

If `.hrb/REVIEW_POLICY.md` changed, inspect that policy diff directly. A proposed policy change is human-owned and cannot authorize itself within the same PR.

Then read **Decisions requiring human judgment** and the complete **Findings by attention** section (or every partition listed in its index).

A1–A4 only determines reading order. It does not mean "must read" versus "safe to skip". Read every finding summary; open underlying evidence only where additional context is useful.

For each material item ask:

- Is this genuinely a decision I need to own?
- What happens if this assumption is wrong?
- Is the evidence chain sufficient to verify the claim, including base/diff/head or absence evidence when needed?
- Did the independent reviewer actually challenge the implementation, or only restate it?

If a decision is vague, redirect:

> Rewrite this as one concrete decision, its consequence, and the minimum evidence I should inspect.

## Gate 3 — Targeted evidence (~2–8 minutes)

Open only the recommended deep reads that correspond to unresolved decisions or findings whose summaries are not sufficient for you to judge.

Ask:

- Does the linked source actually support the brief?
- Is important surrounding context missing?
- Would I make the same decision after seeing the source?

If context is insufficient:

> Deep-review this item only. Show the relevant surrounding code/docs/tests and competing evidence.

## Gate 4 — Verification sanity check (~1–2 minutes)

Read **Verification evidence**.

Ask:

- Which claims are proven by deterministic tooling?
- Which claims are only asserted by an AI reviewer?
- Has sensitive or private evidence been handled without leaking secrets or widening access?
- If evidence was redacted, can I still tell where it came from and which claim it supports?
- Has any sensitive payload leaked into a Raw Finding, persisted review artifact, worker handoff, or final brief instead of being sanitized at the evidence boundary?
- Is the most important business behavior actually exercised?

Do not equate "CI is green" with "the change is correct."

## Stop rules

Pause the review and re-scope when:

- the fixed point is wrong;
- the diff is much larger than expected;
- the total finding set makes one brief impractical to review as a bounded unit and has not been partitioned;
- a finding has no source evidence;
- the brief repeatedly sends you to unrelated files;
- the change crosses an architecture/data/security boundary that was not expected;

When the problem is simply review size, prefer partitioning the brief by topic/module/risk cluster, or splitting the PR when the implementation itself is too broad. Do not hide lower-priority findings to make the review shorter.

## Decision

Choose one:

- **Approve** — material decisions are understood and acceptable.
- **Request changes** — evidence supports a concrete correction.
- **Deep review selected item** — uncertainty remains localized and deserves more context.

The goal is not to read everything.

The goal is to spend human attention where it changes the quality of the decision.
