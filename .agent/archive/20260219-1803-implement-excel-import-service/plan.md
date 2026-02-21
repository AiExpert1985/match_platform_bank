# Plan: Implement Excel Import Service

## Goal
Implement an in-memory Excel import service that reads Bank and Platform files into valid transaction records using strict headers, date-only normalization, and row-level error reporting.

## Scope Boundaries
âœ“ In scope: `.xlsx` parsing for Bank and Platform files
âœ“ In scope: Exact header validation per file source
✓ In scope: Ignore non-required columns in the sheet
âœ“ In scope: Row mapping to `TransactionRecord`
âœ“ In scope: Skip-and-report behavior for invalid rows
âœ“ In scope: Date-only normalization during import
âœ— Out of scope: CSV or other file formats
âœ— Out of scope: Matching/reconciliation rule changes
âœ— Out of scope: Persistence or history tracking
âœ— Out of scope: Major UI redesign

---

## Relevant Contracts

- **Input Contract** â€” Accept two Excel (`.xlsx`) files with source-specific headers.
- **Core Invariant** â€” Keep data in memory only; no persistence across sessions.
- **Safety** â€” Import remains read-only; no editing/deleting/adding records in-place.
- **Deduplication** â€” Identical records in a single file are treated as one logical entry.

---

## Relevant Design Constraints

- **Data Model** â€” Use `TransactionRecord` / `ReconciliationResult` model boundaries.
- **Processing Style** â€” In-memory Dart processing; efficient collection operations.
- **Architecture Direction** â€” Keep feature-first structure and clear service boundaries.
- **i18n/RTL Context** â€” Any user-facing import feedback must stay compatible with Arabic RTL UX.

---

## Execution Strategy
Add an import service that accepts file bytes/path and a source type (bank/platform), then parses `.xlsx` rows through source-specific header maps. Validate presence of exact required headers before row iteration, while allowing and ignoring additional columns. For each row, parse account/amount/date, normalize date to day precision, and convert to `TransactionRecord`; invalid rows are skipped and logged into a structured import report. Keep import logic isolated from UI and reconciliation so downstream modules consume a clean result object. Wire minimal integration points needed for later run-task implementation.

---

## Affected Files

- `/pubspec.yaml` â€” Add Excel parsing dependency for `.xlsx` ingestion. (Contract touch: Input Contract)
- `/lib/features/transactions/application/services/excel_import_service.dart` â€” New core service for schema validation, parsing, and mapping. (Contract touch: Input Contract, Core Invariant)
- `/lib/features/transactions/application/models/import_report.dart` â€” New model for skipped-row diagnostics and import summary. (Contract touch: Safety)
- `/lib/features/transactions/domain/transaction_record.dart` â€” Reuse/adjust only if needed for date-only normalization expectations. (Contract touch: Deduplication)
- `/lib/features/transactions/presentation/...` â€” Integrate import trigger and report display if required by current screen wiring. (No contract impact)


