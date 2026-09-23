# HUMAN.md — Human Review Protocol

This file is for the human using Human Review Brief.

Do not read the whole repository because HRB produced a brief. Start with the brief and expand only where the evidence justifies it.

## Gate 1 — Scope sanity check (~1 minute)

Read only **Review scope**.

Ask:

- Is this the right base / fixed point?
- Is this the right branch, PR, or commit range?
- Is the correct spec / ticket being used?
- Is the brief centered on the actual base→head PR diff rather than an outdated repository summary?

If not, redirect:

> Stop. Rebuild the brief against the correct review scope.

## Gate 2 — Human decisions (~2–5 minutes)

First confirm the brief states whether an **independent specialist review** was completed across the required dimensions.

Read **Decisions requiring human judgment** and **MUST REVIEW**.

For each item ask:

- Is this genuinely a decision I need to own?
- What happens if this assumption is wrong?
- Is the evidence chain sufficient to verify the claim, including base/diff/head or absence evidence when needed?
- Did the independent reviewer actually challenge the implementation, or only restate it?

If a decision is vague, redirect:

> Rewrite this as one concrete decision, its consequence, and the minimum evidence I should inspect.

## Gate 3 — Targeted evidence (~2–8 minutes)

Open only the recommended deep reads that correspond to unresolved decisions or A1 findings.

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
- Is the most important business behavior actually exercised?

Do not equate "CI is green" with "the change is correct."

## Stop rules

Pause the review and re-scope when:

- the fixed point is wrong;
- the diff is much larger than expected;
- the number of A1 findings makes the PR impractical to review as one bounded unit;
- an A1 item has no source evidence;
- the brief repeatedly sends you to unrelated files;
- the change crosses an architecture/data/security boundary that was not expected;
- the brief cannot explain what can safely be skipped.

When the problem is simply review size, prefer splitting the PR or reviewing explicit risk clusters. Do not waive A1 findings to make the review shorter.

## Decision

Choose one:

- **Approve** — material decisions are understood and acceptable.
- **Request changes** — evidence supports a concrete correction.
- **Deep review selected item** — uncertainty remains localized and deserves more context.

The goal is not to read everything.

The goal is to spend human attention where it changes the quality of the decision.
