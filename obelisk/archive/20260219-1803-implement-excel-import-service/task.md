# Task: Implement Excel Import Service

## Goal
Build an Excel import service that loads Bank and Platform transaction files into in-memory records for reconciliation, using strict column mapping and resilient row-level validation.

## Scope
âœ“ Included: Import `.xlsx` Bank and Platform files
âœ“ Included: Enforce exact required headers per source
✓ Included: Ignore any extra columns beyond required headers
âœ“ Included: Map valid rows into `TransactionRecord` with correct source
âœ“ Included: Normalize imported date values to date-only (no time component)
âœ“ Included: Skip invalid rows and return/report row-level import issues
âœ“ Included: Keep processing in-memory and read-only
âœ— Excluded: Non-Excel formats (CSV, JSON, etc.)
âœ— Excluded: Reconciliation algorithm changes
âœ— Excluded: Persistence/database/history features
âœ— Excluded: UI redesign beyond wiring import results

## Constraints
- Preserve input contract: two Excel inputs (Bank and Platform) with source-specific headers.
- Platform headers must be exact: `رقم الحساب`, `تاريخ العملية`, `المبلغ بعد الخصم`.
- Bank headers must be exact: `ACCOUNT_NO`, `NET`, `Transaction Date`.
- Extra columns are allowed in both files and must be ignored.
- Invalid rows must not fail whole import; they are skipped and reported.
- Date handling is date-only for imported records.
- Preserve system invariants: stateless, in-memory, read-only behavior.

## Open Questions (if any)
- None.

## Design-Changes
## Implement Excel Import Service | 2026-02-19

**Summary:**
- Add a dedicated import path for Bank/Platform `.xlsx` inputs with strict source-specific schema validation.

**Architecture / Design (if applicable):**
- Introduce an import service boundary responsible for file parsing, header validation, row mapping, and structured import reporting.
- Keep source column contracts centralized to avoid scattering schema rules.

**Business Logic (if applicable):**
- Parse account/amount/date from exact headers only; normalize dates to day precision.
- Ignore non-required columns when required headers are present.
- Skip malformed rows and surface them in an import report without stopping valid-row ingestion.

**Deferred:**
- User-configurable header aliases.


