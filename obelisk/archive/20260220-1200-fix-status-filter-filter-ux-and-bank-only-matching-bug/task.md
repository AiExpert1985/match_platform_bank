# Task: Fix Status Filter, Filter UX, and Bank-Only Matching Bug

## Goal
Fix incorrect bank-only/platform-only status assignment in the matching engine, make the status filter cover all statuses as separate selectable options, fix filter height inconsistency across all columns, and add clear (X) controls to all filters.

## Scope
✓ Included:
- Split `ReconciliationStatus.unmatched` into `bankOnly` and `platformOnly` enum values
- Update reconciliation service to emit `bankOnly` / `platformOnly` instead of `unmatched`
- Normalize account numbers in `_parseAccount` (strip leading zeros for purely numeric accounts) to fix matching bug
- Add `bankOnly` and `platformOnly` as separate options in the status filter dialog
- Add "الكل" (All) as the first item in the status filter dialog; selecting it clears all others
- Make all filter widgets the same visual height (consistent bordered container)
- Add X (clear) button inside account and amount filters
- Status filter keeps its dropdown/dialog pattern (no X on the outer button; reset via "الكل" inside dialog)
- Date filter already has X — no change

✗ Excluded:
- Adding fullMatch to the status filter (fullMatch rows are excluded from the table entirely)
- Any changes to import logic other than account normalization
- Changes to date parsing or amount parsing

## Constraints
- Account normalization must not break accounts that contain non-numeric characters (letters, dashes, etc.)
- One-to-one matching for fullMatch phase is unchanged
- UI language remains Arabic; RTL layout unchanged
- No new packages

## Open Questions
- None

## Design-Changes

## Fix Status Filter, Filter UX, and Matching Bug | 2026-02-20

**Summary:**
- Split `unmatched` enum value into `bankOnly` and `platformOnly`; normalize account string comparison; add clear controls to all filters.

**Architecture / Design (if applicable):**
- `ReconciliationStatus` enum: `unmatched` removed; `bankOnly` and `platformOnly` added as distinct values.
- `_parseAccount` in `ExcelImportService`: normalize purely-numeric account strings by stripping leading zeros so bank integers and platform text accounts match.
- All filter widgets adopt a uniform visual container (bordered `Container`) so height is consistent across columns.

**Business Logic (if applicable):**
- Bank Only: bank record with no account match in unclaimed platform records → `ReconciliationStatus.bankOnly`.
- Platform Only: unclaimed platform record not surfaced in any non-full pair → `ReconciliationStatus.platformOnly`.

**Deferred:**
- None
