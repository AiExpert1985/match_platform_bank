# Task: Build Full Presentation Layer (UI + State)

## Goal
Build the complete presentation layer: single-screen RTL/Arabic UI with import buttons, generate button, and reconciliation results tables — wired together via Riverpod 3 state management.

## Scope
✓ Included:
- Add `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `build_runner`, `file_picker` to pubspec.yaml
- Rewrite `main.dart`: ProviderScope wrapper, RTL locale, route to MainScreen
- MainScreen layout — three vertical zones with top/bottom SafeArea:
  - **Import zone (top):** Two file-picker buttons side-by-side (bank + platform); each button shows success (✓ + "تم الاستيراد") or failure (✗ + "فشل الاستيراد") status below it
  - **Action zone (middle):** "توليد" (Generate) button — disabled until both imports succeed
  - **Result zone (bottom, scrollable):** Single unified table with 7 columns — platform account, platform amount, platform date | bank account, bank amount, bank date | status. Shows only: partial match, unmatched bank, unmatched platform (full matches excluded). Unmatched bank rows: platform columns empty. Unmatched platform rows: bank columns empty. Rows ordered by status: partial match → unmatched bank → unmatched platform.
- Riverpod `AppNotifier` managing: bank import state, platform import state, reconciliation state
- Generate button triggers `ReconciliationService.reconcile()` from provider state
- Results tables populated from `ReconciliationReport`

✗ Excluded:
- Import error/warning surfacing (skipped rows, malformed data not shown)
- Navigation beyond single screen
- Persistence or database
- Export functionality
- Tests

## Constraints
- All data in-memory only (no persistence between sessions)
- Read-only operation — no editing or deleting records in UI
- RTL layout globally enforced; all UI text in Arabic
- Riverpod 3 with generator syntax (`@riverpod` annotation)
- SafeArea applied at top and bottom of screen
- Verify latest stable package versions during implementation (per ai-engineering guidelines)

## Open Questions
- None

## Design-Changes

## Build Full Presentation Layer | 2026-02-19

**Summary:**
- Add complete presentation layer to the transactions feature: screen, widgets, and Riverpod state notifier.

**Architecture / Design:**
- New `presentation/` sublayer under `lib/features/transactions/` with `screens/`, `widgets/`, and `providers/` subdirectories.
- Single `AppNotifier` (Riverpod `@riverpod` class) owns all UI state: bank import, platform import, and reconciliation — keeping coupled state co-located.
- Sealed state classes (`ImportState`, `ReconciliationState`) model each stage (idle / loading / success / failure).

**Deferred:**
- None
