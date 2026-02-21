# Review: Fix Matching Algorithm and Show All Statuses

**Status:** APPROVED

1. **Goal Achieved: ✔**
   - `ReconciliationService.reconcile()` — account sets built at lines 10–11; platform-only loop lines 13–21; bank-only loop lines 23–31; cartesian product within account intersection lines 33–56. Bug (accounts shown bank-only despite existing in both files) is resolved: the old algorithm used `unclaimedPlatform` which excluded already-claimed accounts; the new algorithm uses full account sets for the split decision.
   - `results_table.dart` line 62–64: `_sort` no longer filters out `fullMatch`; all 6 statuses are sorted and displayed.
   - `_selectedStatuses` defaults to `Set.of(ReconciliationStatus.values)` (line 48) — all statuses shown on first render.
   - Number column present in filter row (line 211), header row (line 271), and data row (line 294) with `${index + 1}`.

2. **Contracts Preserved: ✔**
   - Deduplication: unchanged — `ExcelImportService` still uses `uniqueRecords` Set.
   - Safety (read-only): no editing of source records — service only reads `bankRecords` and `platformRecords`.
   - New matching algorithm contract added to `contracts-summary.md` under `## Unprocessed`.
   - `_normalizeAmount` retained in service for consistent 3-decimal comparison.

3. **Scope Preserved: ✔**
   - Only files listed in plan were modified: `reconciliation_service.dart`, `results_table.dart`, `contracts-summary.md`, `design-summary.md`.
   - `ExcelImportService`, `AppNotifier`, `ReconciliationReport`, `ReconciliationResult`, `main_screen.dart` — all untouched.
   - No new packages introduced.

**Files Verified:**
- `lib/features/transactions/application/services/reconciliation_service.dart`
- `lib/features/transactions/presentation/widgets/results_table.dart`
- `obelisk/contracts/contracts-summary.md`
- `obelisk/design/design-summary.md`

**Notes:** None.
