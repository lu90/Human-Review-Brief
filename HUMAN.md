# HUMAN.md — Human Review Protocol

This file is for the human using Human Review Brief.

Do not read the whole repository because HRB produced a brief. Start with the brief and expand only where the evidence justifies it.

## Choose the stage/version first

For an effective `hrb-final-v2` Final brief, check the exact candidate/head, current report, existing verification and Code Review evidence, unresolved findings, and concrete Owner decisions. Read the decision-ready brief in this chat; GitHub must contain the same-head brief and your actual decision, read back before routing.

Dedicated eight-dimension Final coverage is no longer guaranteed, especially Operations / Observability, Performance / Compatibility and Adversarial Challenge. It is not transferred to Code Review and no equivalent coverage is promised. Final HRB does not rerun specialist review, tests or remediation verification. Missing evidence required by the effective contract goes to its responsible owner; removed dedicated coverage is not a missing-evidence gate.

For `spec_review` and work still pinned to `hrb-v1`, use Gates 1–4 below, including the independent review checks. Historical records are unchanged; an in-flight switch needs your explicit contract/scope decision and preserved unresolved Finding ownership. A candidate cannot apply its proposed gates to approve itself. WORKFLOW-EVOLUTION-B remains under its pre-B contract unless separately authorized otherwise.

## Gate 1 — Scope sanity check (~1 minute)

Read only **Review scope**.

Ask:

- Is this the right base / fixed point?
- Is this the right branch, PR, or commit range?
- Is the correct spec / ticket being used?
- If project context is linked, does its Phase/ChangeSet point to the current authoritative scope, fixed shared-contract versions, progress/report, and actual Round/Decision records rather than copied approval labels?
- Is the brief bound to the actual current PR head, with full or eligible delta scope clearly identified?
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

If this is round 2+, also confirm that:

- an independent Fresh Review ran before separate remediation verification;
- if Fresh Review used a delta, its affected boundary and every dimension's newly reviewed versus reused coverage are explicit, with valid prior pins and unchanged authority;
- uncertain/high-risk/broad impact or missing reuse evidence escalated to full review, and previous approval was not transferred to the new head;
- Remediation Review mode isolation status and method are reported;
- an isolated runtime was not marked `achieved` if the remediation handoff contained current-round Fresh Review findings or another forbidden input.

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
- When resuming linked work, were shared-contract refs and revisions compared with the reviewed scope, including any recovered legacy snapshot? A true unchanged-scope flag does not settle a version mismatch.

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

## Decision (both branches)

Choose one:

- **Approve** — material decisions are understood and acceptable.
- **Request changes** — evidence supports a concrete correction.
- **Deep review selected item** — uncertainty remains localized and deserves more context.

For **Request changes**, also state whether the current Spec is still valid or must change. For each Finding that matters to the route, make the disposition explicit: accept it, remediate it now, defer it with a reason, require a Spec change, or leave it unresolved for deeper review. You do not need to invent remediation constraints; an explicit empty constraint set is valid.

The Orchestrator may persist partial decisions while you are still reviewing. Partial state does not authorize engineering progress. Once the required decisions are complete, the Orchestrator must save a Review Decision Record tied to the exact Review Round Record and review head, including the human statement it relied on. The record, not the surrounding conversation, becomes the recoverable decision state.

If you later change or complete the decision, the new Review Decision Record must explicitly supersede the prior record. A Fresh Orchestrator must validate the revision chain, Finding IDs, decision source, current head, Spec status, and internal consistency before routing.

Approval of an HRB is not merge permission, tracker-write permission, or any other external-write authorization.

Project association adds navigation, not another approval. A small task follows its applicable route without creating unnecessary Spec/HRB records; entering HRB retains the gates for its effective stage/version. Keeping the same PR preserves valid history, while a split into new PRs requires their own applicable decisions. Old Finding IDs remain source provenance and old approvals do not transfer to the new scope or head.

The goal is not to read everything.

The goal is to spend human attention where it changes the quality of the decision.
