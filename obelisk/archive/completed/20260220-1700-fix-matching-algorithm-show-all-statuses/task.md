# Task: Show All Statuses, Checkbox Filter, Row Numbering, and Fix Matching Algorithm

## Goal
Fix the matching algorithm so account-level pairing is correct; show full-match records in the results table; replace the status filter with an all-checked-by-default checkbox list (no "select all"); add a sequential row number column that resets on filter change; and record the new matching algorithm as a contract.

## Scope
✓ Included:
- Rewrite `ReconciliationService.reconcile()` with the new account-first matching algorithm
- Show `fullMatch` records in the results table (remove the exclusion filter in `_sort`)
- Add `fullMatch` as a selectable status in the status filter dialog
- Remove "Select All / الكل" option from the status filter dialog
- Default status filter to all statuses selected (show everything on first render)
- Add a row-number column (first column, 1-based, resets with each filter change)
- Add contract entry for the new matching algorithm

✗ Excluded:
- Export / generate report to file (no new button or file-writing feature)
- Changes to import logic (`ExcelImportService`) — deduplication already happens there
- UI changes beyond the results table and status filter
- Tests

## Constraints
- Deduplication (same account + amount + date within one file) is already enforced by `ExcelImportService` via `uniqueRecords` Set — no change needed there
- The new algorithm does NOT claim records; a record may appear in multiple result rows (cartesian product within account groups)
- Status filter default must be "all checked" — not empty-set-means-all as before
- No external packages needed for the checkbox dialog (native Flutter `CheckboxListTile` is sufficient)
- RTL layout must be preserved
- `_totalWidth` must be updated to include the new number column width

## Open Questions
- None

## Contract-Changes

## Fix Matching Algorithm and Show All Statuses | 2026-02-20

**Action:** update
**Change:**
- Replace "One-to-one applies only to full matches. For partial matches, all ambiguous candidate pairs are surfaced as separate result rows." with:
  **Matching Algorithm (authoritative):**
  1. Deduplication is applied per-file at import time (same account + amount + date = one entry).
  2. Account-level split: platform records whose account does not appear in any bank record → Platform Only; bank records whose account does not appear in any platform record → Bank Only.
  3. Cross-file pairing: for each account number present in both files, every bank record with that account is paired with every platform record with that account (cartesian product). Each pair is independently assigned a status:
     - Same amount AND same date → Full Match
     - Same amount, different date → Different Date
     - Same date, different amount → Different Amount
     - Different date AND different amount → Different Date and Amount
  4. No record is claimed; a single record may appear in multiple result rows.

## Design-Changes

## Fix Matching Algorithm and Show All Statuses | 2026-02-20

**Summary:**
- Replace phase-based claiming algorithm with a simple account-first grouping + cartesian-product matching; show all statuses (including full match) in the results table with an all-selected checkbox filter and a sequential row number column.

**Architecture / Design (if applicable):**
- `ReconciliationService.reconcile()` rewritten: build `bankAccounts` and `platformAccounts` sets, split bank-only / platform-only by account set membership, then iterate account intersection and emit all bank × platform pairs per account group.
- `_TableState._selectedStatuses` initialises to `Set.of(ReconciliationStatus.values)` (all selected); filter guard changes from `isNotEmpty &&` to unconditional `contains` check.
- New number column added to `ResultsTable` (`_colNum = 50.0`); `_totalWidth` updated accordingly.
- `_StatusFilter._options` expanded to include `fullMatch`; "الكل" `CheckboxListTile` removed from dialog.

**Business Logic (if applicable):**
- Full-match records are now visible in the results table by default.
- Row numbers (1-based) reflect the currently visible (post-filter) rows and reset on every filter change.

**Deferred:**
- None
