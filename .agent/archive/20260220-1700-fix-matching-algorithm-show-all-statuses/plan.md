# Plan: Show All Statuses, Checkbox Filter, Row Numbering, and Fix Matching Algorithm

## Goal
Fix the account-first matching algorithm, show full-match records in the table, update the status filter to all-checked-by-default checkboxes (no "select all"), add a sequential row-number column, and record the new algorithm as a contract.

## Scope Boundaries
✓ In scope: `ReconciliationService`, `ResultsTable` widget, status filter dialog, contract/design summary files
✗ Out of scope: `ExcelImportService`, file export, tests, any other UI

---

## Relevant Contracts

- **Matching Algorithm** — New contract: account-set split first (bank-only / platform-only), then cartesian product within matching accounts; no claiming; each pair assigned status independently.
- **One-to-one matching** — Being replaced: old "one-to-one for full matches" is superseded by the new algorithm above.
- **Deduplication** — Already enforced at import time; no change needed.
- **Safety / Read-only** — No editing of source records; results are computed in-memory only.

---

## Relevant Design Constraints

- **Riverpod 3 / single AppNotifier** — ReconciliationService is called from `AppNotifier.reconcile()`; no state management changes required.
- **RTL layout** — Column order and text alignment must remain RTL-safe.
- **Fixed-width table columns** — `_totalWidth` must be updated when adding the number column.
- **No external packages** — Native Flutter `CheckboxListTile` inside `AlertDialog` is sufficient.

---

## Execution Strategy

1. **Rewrite `ReconciliationService`**: Replace the three-phase claiming algorithm with (a) build account sets, (b) emit bank-only / platform-only by set membership, (c) iterate account intersection and emit all bank × platform pairs, each independently categorised.
2. **Update `ResultsTable._sort()`**: Remove the `.where` that excluded `fullMatch` records; add `fullMatch` to the sort order (position 0, shown first).
3. **Update `ResultsTable` display helpers**: Add Arabic label `'تطابق كامل'` and green colour for `fullMatch`.
4. **Update status filter**: Initialise `_selectedStatuses` to `Set.of(ReconciliationStatus.values)`; change filter guard from `isNotEmpty && !contains` to just `!contains`; add `fullMatch` to `_StatusFilter._options`; remove the "الكل" `CheckboxListTile` from the dialog.
5. **Add row-number column**: Add `_colNum = 50.0` constant; update `_totalWidth`; add an empty filter cell, a `'#'` header cell, and a 1-based index data cell as the first column in every row builder.
6. **Update contracts and design summaries** with the new matching algorithm entry.

---

## Affected Files

- `lib/features/transactions/application/services/reconciliation_service.dart` — Full rewrite of `reconcile()` method; remove `_fullKey`, `_groupByKey`; add `_groupByAccount`; keep `_normalizeAmount`. No contract impact beyond the new algorithm contract.
- `lib/features/transactions/presentation/widgets/results_table.dart` — Remove fullMatch exclusion in `_sort`; update `_sortOrder`, `_statusColor`, `_statusLabel`; change filter default and guard; add number column in filter row, header row, and data row; update `_StatusFilter._options` and dialog; update `_totalWidth`. No contract impact.
- `obelisk/contracts/contracts-summary.md` — Add matching algorithm contract entry.
- `obelisk/design/design-summary.md` — Add design change entry.
