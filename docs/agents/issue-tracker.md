# GOVERNANCE-01 engineering entry

This repository owns the HRB review/recovery integration slice, `GOV-01-4`, in the shared GOVERNANCE-01 ChangeSet. The project Tracker convention and ticket state have one owner:

- [Main project Tracker entry](../../../matt-workflow-guidelines/docs/agents/issue-tracker.md).
- [Canonical GOVERNANCE-01 ticket ledger](../../../matt-workflow-guidelines/docs/delivery/GOVERNANCE-01_TICKETS.md), IDs `GOV-01-1` through `GOV-01-5`.

These sibling-source links resolve in the restored engineering-workflow workspace. Integration must pin the final main-source revision when exporting a standalone handoff. This file is a pointer, not a second ticket ledger; it creates no Issues, PRs, or external-write authorization.

The approved scope is the [Canonical Spec at 42f1feb9fa93c45f0d847024468a2cfdc25a37a0](https://github.com/lu90/matt-workflow-guidelines/blob/42f1feb9fa93c45f0d847024468a2cfdc25a37a0/docs/delivery/GOVERNANCE-01_CANDIDATE_SPEC.md) and its pinned [Owner Proposal](https://github.com/lu90/matt-workflow-guidelines/blob/42f1feb9fa93c45f0d847024468a2cfdc25a37a0/docs/delivery/GOVERNANCE-01_OWNER_PROPOSAL.md). Local HRB source baseline: `7caef3543fa526d04efd426c570778425a63f3ea`; source branch: `feat/governance-project-context`.

The implementation is described in [the local slice report](../delivery/GOVERNANCE-01_HRB_IMPLEMENTATION_REPORT.md). Round/Decision/Payload records remain the durable HRB authorities; this entry does not copy their decisions. As project context, this file has no Reviewer-instruction authority under `.hrb/REVIEW_POLICY.md`.
