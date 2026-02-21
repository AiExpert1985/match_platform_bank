# Design Summary

Generated: 2026-02-21

## System Architecture

- **Platform**: Flutter for Desktop (Windows).
- **State Management**: Riverpod 3 (Generator syntax, `@riverpod` class).
- **UI Layout**: Single-screen, 3 vertical sections — Import, Action, Result.
- **Layout Direction**: RTL globally enforced.
- **UI Language**: Arabic.
- **Processing**: In-memory, using Dart Map/Set structures for O(n) / O(n log n) matching.
- **Feature structure**: `lib/features/transactions/` with `application/` and `presentation/` sublayers.

## Data Model

- `TransactionRecord` — immutable Dart class; fields: date, account, amount, source. Manual `==`/`hashCode` for Set/Map compatibility.
- `ReconciliationResult` — immutable; fields: status (`ReconciliationStatus`), bank_record, platform_record.
- `ReconciliationReport` — aggregate under `application/models/`; contains result list + precomputed summary counts.
- `ImportReport` — mirrors `ReconciliationReport` pattern; produced by `ExcelImportService`.
- Amount equality: 3-decimal precision.

## Core Design Principles

- Import service boundary: parses file, validates headers, maps rows, produces structured report. Required headers are exact-match only; non-required columns ignored; malformed rows skipped and surfaced without stopping valid ingestion.
- Account normalization: `_normalizeAccount` strips leading zeros from purely-numeric strings, aligning bank integer cells with platform text cells.
- Dates normalized to day precision.
- Sealed state classes (`ImportState`, `ReconciliationState`) with variants: idle / loading / success / failure.
- `AppNotifier` (single Riverpod notifier) co-locates all UI state: bank import, platform import, reconciliation.

## Modules

### ExcelImportService (`application/services/`)
Parses Excel files into `List<TransactionRecord>` and produces `ImportReport`. Centralizes source-column schema rules.

### ReconciliationService (`application/services/`)
Accepts two `List<TransactionRecord>` (bank, platform), returns `ReconciliationReport`.

**Current algorithm (20260220-1700):**
1. Build `bankAccounts` and `platformAccounts` account-key sets.
2. Records whose account is absent from the opposing set → `bankOnly` / `platformOnly`.
3. For accounts in the intersection, emit all bank × platform pairs (cartesian product, no claiming). Classify each pair:
   - `fullMatch`: account + normalized amount + date all identical.
   - `differentDate`: account + normalized amount match; date differs.
   - `differentAmount`: account + date match; normalized amount differs.
   - `differentDateAndAmount`: account matches only.

### Presentation Layer (`presentation/`)
Subdirectories: `screens/`, `widgets/`, `providers/`.

- `ResultsTable`: `StatefulWidget` owning per-column filter state (account, amount, date, status).
- Sticky-header achieved via `Column` → [filter row, header row, `Expanded(ListView.builder)`] — no external packages.
- `LayoutBuilder` centres fixed-width table on wide screens.
- Number column (width `50.0`) prepended; row numbers are 1-based, reflect post-filter visible rows, reset on filter change.
- Status filter: shows "الكل" when all statuses selected; otherwise shows selected count. All statuses selected by default (`Set.of(ReconciliationStatus.values)`).

### ReconciliationStatus Enum
Current values: `fullMatch`, `differentDate`, `differentAmount`, `differentDateAndAmount`, `bankOnly`, `platformOnly`.
Removed: `partialMatch`, `unmatched`.

## Open Design Questions

_(none)_

## Unprocessed
