# Task: Expand Matching Logic, Add Column Filters, and UI Polish

## Goal
Replace the single "Partial Match" category with three account-based subcategories, add per-column filtering to the results table, fix column headers, center the table, apply status-based font colors, and add a footer.

## Scope
✓ Included:
- Reconciliation engine: replace "Partial Match" with three new result statuses (DifferentDate, DifferentAmount, DifferentDateAndAmount)
- Result model: add new status enum values
- Per-column filter row above column headers (Date picker, Status dropdown, Account live filter, Amount on-blur/Enter filter)
- Sticky/fixed column headers (do not scroll with table body)
- Horizontally center the results table
- Per-status font colors (visually distinct for each status)
- Footer text at the bottom of the screen

✗ Excluded:
- Changes to full match logic
- Changes to deduplication logic (exact duplicates: same account + amount + date are ignored)
- Sorting behavior
- Export/print functionality
- Any new persistence or external service

## Constraints
- Full match (account + amount + date) runs first and claims records before any partial phase
- All non-full-match candidate pairs are surfaced (no claiming); one bank record may appear in multiple rows if multiple platform candidates exist
- Deduplication applies only to exact duplicates (same account + amount + date within one file); duplicate account numbers alone do not trigger deduplication
- Safety contract: read-only, no editing
- RTL layout globally enforced
- Riverpod 3 (Generator syntax) for any state changes
- UI language: Arabic

## Open Questions
- None

---

## Contract-Changes

## Expand Matching Logic | 2026-02-20

**Action:** update
**Change:**
- "Matching Types: 2. Partial Match: Identical Account and Amount, different Date." →
  Remove "Partial Match" and replace with three subcategories:
  2. **Different Date**: Identical Account and Amount, different Date.
  3. **Different Amount**: Identical Account and Date, different Amount.
  4. **Different Date and Amount**: Identical Account only (Amount and Date both differ).

---

## Design-Changes

## Expand Matching Logic, Add Column Filters, and UI Polish | 2026-02-20

**Summary:**
- Expand reconciliation matching subcategories, add per-column table filters, sticky headers, centered layout, status font colors, and a footer.

**Architecture / Design:**
- `ReconciliationResult.status` enum gains three new values: `differentDate`, `differentAmount`, `differentDateAndAmount`; `partialMatch` is removed or mapped to `differentDate` if it exists.
- Matching phases: full match phase unchanged; partial phase now runs three sub-passes (date-only diff, amount-only diff, both-diff) against unclaimed records, account number as the sole grouping key.
- Per-column filter state owned by existing `AppNotifier` or a dedicated local widget state — filtered list is a derived computation, not stored separately.

**Business Logic:**
- Matching priority: full → differentDate → differentAmount → differentDateAndAmount.
- All non-full-match pairs are surfaced (no claiming); edge-case duplicate account numbers within one file are matched normally (only exact-duplicate rows are ignored).

**Deferred:**
- None
