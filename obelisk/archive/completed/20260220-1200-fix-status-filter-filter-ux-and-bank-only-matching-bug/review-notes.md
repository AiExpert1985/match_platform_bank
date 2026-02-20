# Review: Fix Status Filter, Filter UX, and Bank-Only Matching Bug

**Status:** APPROVED

1. **Goal Achieved: ✔**
   - `ReconciliationStatus.unmatched` removed; `bankOnly` and `platformOnly` added (`reconciliation_result.dart:3–10`).
   - Reconciliation service emits `bankOnly` at line 66 and `platformOnly` at line 77 (`reconciliation_service.dart`).
   - `_normalizeAccount` strips leading zeros from purely-numeric strings, fixing the bank-integer vs platform-text mismatch (`excel_import_service.dart:238–242`).
   - Status filter dialog now lists all 5 statuses including separate "بنك فقط" and "منصة فقط" entries, with "الكل" as the first checkbox (`results_table.dart:529–535`, `572–590`).
   - `_AccountFilter` and `_AmountFilter` now use the same bordered `Container` pattern as `_DateFilter`/`_StatusFilter`, producing uniform height across all filter cells (`results_table.dart:342–462`).
   - X (clear) icon appears inside account and amount filters when text is non-empty, via `ValueListenableBuilder` (`results_table.dart:374–381`, `448–455`).

2. **Contracts Preserved: ✔**
   - One-to-one fullMatch phase unchanged (`reconciliation_service.dart:14–28`).
   - No persistence introduced; all data remains in memory.
   - Read-only: no record editing anywhere.
   - Matching types contract updated: `bankOnly` = bank record with no account match; `platformOnly` = unclaimed platform record not surfaced. Semantically equivalent to the prior `unmatched` split by null-check; now made explicit in the enum.

3. **Scope Preserved: ✔**
   - Only the four files listed in the plan were modified.
   - No new packages introduced.
   - `fullMatch` remains excluded from the table and is not added to filter options.
   - Date filter X button unchanged.
   - Amount and date parsing logic unchanged.

**Files Verified:**
- `lib/features/transactions/domain/reconciliation_result.dart`
- `lib/features/transactions/application/services/reconciliation_service.dart`
- `lib/features/transactions/application/services/excel_import_service.dart`
- `lib/features/transactions/presentation/widgets/results_table.dart`

**Notes:** Three minor mechanical divergences logged in `implementation-notes.md`. All are consistent with plan intent and ai-engineering guidelines.
