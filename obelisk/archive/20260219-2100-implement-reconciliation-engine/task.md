# Task: Implement Reconciliation Engine

## Goal
Build a pure Dart `ReconciliationService` that takes two lists of `TransactionRecord` (bank and platform) and produces a `ReconciliationReport` containing all `ReconciliationResult` items categorized by Full Match, Partial Match, and Unmatched.

## Scope
✓ Included:
- `ReconciliationReport` model (mirroring `ImportReport` pattern)
- `ReconciliationService` pure Dart service
- Full Match logic: identical account + amount + date → one-to-one enforced
- Partial Match logic: identical account + amount, different date → all ambiguous candidate pairs surfaced as separate result rows
- Unmatched logic: bank records with no full or partial match; platform records not claimed by full match and not surfaced in any partial match
- Summary counts on `ReconciliationReport` (fullMatch, partialMatch, unmatchedBank, unmatchedPlatform)

✗ Excluded:
- Riverpod providers / state management layer
- UI
- Tests (unless explicitly requested)

## Constraints
- One-to-one enforcement applies only to full matches: each bank record fully matches at most one platform record, and vice versa
- Partial matches do not claim records; all ambiguous pairings are surfaced for human review
- Monetary comparison uses 3-decimal precision (consistent with `TransactionRecord._normalizedAmount`)
- Feature-first folder structure; follow existing patterns in `application/models/` and `application/services/`
- No Riverpod dependencies; pure Dart only

## Open Questions
- None

## Contract-Changes

## Implement Reconciliation Engine | 2026-02-19

**Action:** update
**Change:**
- "One-to-one matching enforced. A record can match exactly one other record or none." →
  One-to-one applies **only to full matches**. For partial matches, all ambiguous candidate pairs are surfaced as separate result rows.

## Design-Changes

## Implement Reconciliation Engine | 2026-02-19

**Summary:**
- Introduce a pure Dart reconciliation service that matches bank vs platform records into Full Match, Partial Match, and Unmatched results.

**Architecture / Design:**
- New service boundary: `ReconciliationService` under `application/services/`, takes two `List<TransactionRecord>` and returns `ReconciliationReport`.
- New model: `ReconciliationReport` under `application/models/`, mirrors `ImportReport` pattern with result list and precomputed summary counts.
- Matching priority: full match phase runs first and claims records; partial match phase operates only on unclaimed records.

**Business Logic:**
- Full match: identical account + normalized amount + date; one-to-one enforced.
- Partial match: identical account + normalized amount, different date; all candidate pairs surfaced (no claiming).
- Unmatched bank: bank record with no full match and no partial match candidates.
- Unmatched platform: platform record not claimed by full match and not surfaced in any partial match.

**Deferred:**
- None
