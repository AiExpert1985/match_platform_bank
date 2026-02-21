# Plan: Implement Reconciliation Engine

## Goal
Build a pure Dart `ReconciliationService` and `ReconciliationReport` model that match bank vs platform `TransactionRecord` lists into categorized results.

## Scope Boundaries
✓ In scope: `ReconciliationReport` model, `ReconciliationService`, full/partial/unmatched logic, summary counts
✗ Out of scope: Riverpod providers, UI, tests

---

## Relevant Contracts

- **Matching Types** — Full Match (account + amount + date), Partial Match (account + amount, different date), Unmatched (no match).
- **One-to-one (full match only)** — Each bank record fully matches at most one platform record and vice versa. Partial matches do not claim records; all ambiguous pairs are surfaced.
- **Deduplication** — Already enforced by `ExcelImportService`; engine receives clean lists.
- **Precision** — Monetary comparison at 3-decimal precision, consistent with `TransactionRecord._normalizedAmount` logic `((amount * 1000).roundToDouble() / 1000)`.
- **Safety** — Read-only; engine does not mutate input records.
- **Stateless** — No persistence; all processing in-memory.

---

## Relevant Design Constraints

- **Feature-first structure** — New files go under `lib/features/transactions/application/`.
- **Single responsibility** — Service does matching only; report model holds results and counts.
- **Junior-readable** — Early returns, no deep nesting, clear named helpers.
- **No Riverpod** — Pure Dart; no provider dependencies.

---

## Execution Strategy

Phase 1 (Full Match): Build a map keyed by `(account, normalizedAmount, date)` from platform records. Iterate bank records; for each with a key hit, claim one platform record and emit a `fullMatch` result. Claimed platform records are tracked in a `Set`.

Phase 2 (Partial Match): Build a map keyed by `(account, normalizedAmount)` from unclaimed platform records. Iterate bank records that had no full match; for each, collect all platform records with the same key but a different date. Emit a `partialMatch` result for every candidate pair. Track platform records surfaced in partial matches in a separate `Set`.

Phase 3 (Unmatched Bank): Any bank record with no full match and no partial match candidates emits an `unmatched` result with `platformRecord: null`.

Phase 4 (Unmatched Platform): Any platform record neither claimed by a full match nor surfaced in a partial match emits an `unmatched` result with `bankRecord: null`.

`ReconciliationReport` is constructed from the combined results list; summary counts are computed as getters from the list to keep the model simple.

---

## Affected Files

- `lib/features/transactions/application/models/reconciliation_report.dart` — New model: holds `List<ReconciliationResult>` and exposes `fullMatchCount`, `partialMatchCount`, `unmatchedBankCount`, `unmatchedPlatformCount` as getters. No contract impact.
- `lib/features/transactions/application/services/reconciliation_service.dart` — New service: `ReconciliationReport reconcile(List<TransactionRecord> bankRecords, List<TransactionRecord> platformRecords)`. Enforces one-to-one full match contract, surfaces all ambiguous partial match pairs, emits unmatched for uncovered records.
