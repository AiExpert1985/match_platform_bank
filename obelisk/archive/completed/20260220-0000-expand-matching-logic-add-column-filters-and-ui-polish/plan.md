# Plan: Expand Matching Logic, Add Column Filters, and UI Polish

## Goal
Replace "Partial Match" with three account-based subcategories, add per-column sticky filters, center the table, apply status font colors, and add a footer.

## Scope Boundaries
✓ In scope:
- New status enum values: `differentDate`, `differentAmount`, `differentDateAndAmount`; remove `partialMatch`
- Rework reconciliation service partial phases (3 sub-phases after full match)
- Update report computed counts
- Per-column filter row (sticky with headers)
- Sticky column headers
- Centered table layout
- Per-status font colors (Arabic labels + color)
- Footer text at bottom of screen

✗ Out of scope:
- Full match logic changes
- Deduplication logic changes
- Export/print functionality
- Adding new persistence

---

## Relevant Contracts

- **Matching Contract** — Full match (account + amount + date) runs first and claims records one-to-one; no claiming for non-full phases.
- **Non-full match surfacing** — All candidate pairs for `differentDate`, `differentAmount`, `differentDateAndAmount` are surfaced as separate rows (no claiming).
- **Deduplication** — Exact duplicates (same account + amount + date) within one file are ignored; duplicate account numbers alone are matched normally.
- **Safety** — Read-only; no editing of records.

---

## Relevant Design Constraints

- **Riverpod 3 (Generator syntax)** — Any new state must use `@riverpod` / `AsyncNotifier` patterns.
- **RTL layout** — Globally enforced; no LTR widgets introduced.
- **Feature-first structure** — Changes stay inside `lib/features/transactions/`.
- **Single responsibility** — Each function/class ~20–30 lines; early returns.
- **Library research required** — Sticky header implementation must verify current Flutter approach (no assumption on package availability).

---

## Execution Strategy

Phase 1 targets the domain and service layer: add three new enum values to `ReconciliationStatus`, remove `partialMatch`, and update `ReconciliationService` to run three sub-phases (differentDate → differentAmount → differentDateAndAmount) on unclaimed platform records after full match. Phase 2 updates `ReconciliationReport` to expose counts for each new status. Phase 3 rebuilds `ResultsTable` with sticky headers, a per-column filter row (date picker / dropdown / live text / amount-on-enter), centered layout, and per-status font colors. Phase 4 adds the footer to `MainScreen` and updates Arabic status labels throughout.

---

## Affected Files

- `lib/features/transactions/domain/reconciliation_result.dart` — Replace `partialMatch` with `differentDate`, `differentAmount`, `differentDateAndAmount`; no contract impact beyond the approved update.
- `lib/features/transactions/application/services/reconciliation_service.dart` — Rework partial phases: phase 2 = account+amount key (differentDate), phase 3 = account+date key (differentAmount), phase 4 = account key (differentDateAndAmount); update `_partialKey` helpers accordingly.
- `lib/features/transactions/application/models/reconciliation_report.dart` — Replace `partialMatchCount` with `differentDateCount`, `differentAmountCount`, `differentDateAndAmountCount` computed getters.
- `lib/features/transactions/presentation/widgets/results_table.dart` — Add sticky header + filter row, center table, per-status colors, update sort order and status labels for new statuses.
- `lib/features/transactions/presentation/screens/main_screen.dart` — Add footer widget at bottom of screen.
- `lib/features/transactions/presentation/providers/app_state.dart` — No structural change expected; verify no `partialMatch` references.
- `lib/features/transactions/presentation/providers/app_notifier.dart` — No structural change expected; verify no `partialMatch` references.
