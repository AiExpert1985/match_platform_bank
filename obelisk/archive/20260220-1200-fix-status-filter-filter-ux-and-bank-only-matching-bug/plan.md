# Plan: Fix Status Filter, Filter UX, and Bank-Only Matching Bug

## Goal
Fix incorrect bank-only/platform-only matching, split the status enum, and add clear controls and height consistency to all filters.

## Scope Boundaries
✓ In scope: enum split, account normalization, filter height, X buttons, status filter options
✗ Out of scope: fullMatch in filter, new packages, date/amount parsing changes

---

## Relevant Contracts

- **Matching Types** — `bankOnly` = bank record with no account match in unclaimed platform records; `platformOnly` = unclaimed platform record not surfaced in any pair.
- **One-to-one matching** — applies only to fullMatch phase; unchanged.
- **Read-only** — no editing of records.

---

## Relevant Design Constraints

- **Riverpod 3 state** — filter state lives in `_TableState`; no provider changes needed.
- **Arabic / RTL** — all labels remain Arabic.
- **No new packages** — use only existing Flutter/Material widgets.

---

## Execution Strategy

Split `ReconciliationStatus.unmatched` into `bankOnly` and `platformOnly` in the domain model first, then update the reconciliation service to emit these new values. Normalize account numbers in `_parseAccount` to strip leading zeros from purely-numeric strings (the root cause of the matching bug). Update all switch expressions in `results_table.dart` to handle the new enum values, expand the status filter options to include `bankOnly` and `platformOnly` with "الكل" as the first list item, refactor `_AccountFilter` and `_AmountFilter` to use a uniform bordered `Container` wrapper (matching DateFilter/StatusFilter visual height), and add a clear X icon inside each text-based filter widget.

---

## Affected Files

- `lib/features/transactions/domain/reconciliation_result.dart`
  — Replace `unmatched` with `bankOnly` and `platformOnly` in `ReconciliationStatus` enum. No contract impact beyond the enum definition itself.

- `lib/features/transactions/application/services/reconciliation_service.dart`
  — Emit `ReconciliationStatus.bankOnly` (line 66) and `ReconciliationStatus.platformOnly` (line 76-80) instead of `unmatched`. No other logic change.

- `lib/features/transactions/application/services/excel_import_service.dart`
  — In `_parseAccount` (line 228): after getting raw string, if it is purely numeric strip leading zeros (e.g. `"012345"` → `"12345"`) so bank integer accounts and platform text accounts resolve to the same key. Fixes the bank-only matching bug.

- `lib/features/transactions/presentation/widgets/results_table.dart`
  — Multiple changes:
  1. `_sortOrder` (line 117): replace `unmatched when bankRecord != null` / `unmatched` branches with `bankOnly` / `platformOnly`.
  2. `_statusColor` (line 126): same switch update.
  3. `_statusLabel` (line 136): same switch update.
  4. `_StatusFilter._options` (line 478): replace single `unmatched` entry with `bankOnly` → 'بنك فقط' and `platformOnly` → 'منصة فقط'; add "الكل" as first item in the dialog checkbox list.
  5. `_AccountFilter` (line 343): refactor to use bordered `Container` wrapper + `ValueListenableBuilder` to show X clear icon when text is non-empty.
  6. `_AmountFilter` (line 365): same refactor; pressing X also calls `onApply('')` to reset the applied filter.
