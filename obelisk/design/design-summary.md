# Design Summary

Generated: 2026-02-19

## System Architecture
_(empty — populated after maintenance)_

## Data Model
_(empty — populated after maintenance)_

## Core Design Principles
_(empty — populated after maintenance)_

## Modules
_(empty — populated after maintenance)_

## Open Design Questions
_(empty — populated after maintenance)_


## Unprocessed

## 20260219-1341 | Implement Core Data Models

**Architecture / Design (if applicable):**
- Implements `TransactionRecord` and `ReconciliationResult` as immutable Dart classes with manual `==` and `hashCode` overrides for Set/Map compatibility.

**Business Logic (if applicable):**
- Enforces 3-decimal precision on amount equality checks.

---

- **Tech Stack**: Flutter for Desktop (Windows).
- **State Management**: Riverpod 3 (Generator syntax).
- **UI Language**: Arabic.
- **Layout Direction**: Right-to-Left (RTL) globally enforced.
- **Architecture**: Single-screen architecture with 3 vertical sections (Import, Action, Result).
- **Processing**: In-memory data processing using Dart Map/Set structures for O(n) or O(n log n) matching performance.
- **Data Model**: 
    - `TransactionRecord` (date, account, amount, source).
    - `ReconciliationResult` (status, bank_record, platform_record).
- **UX**: Simple, clean table layout.

## 20260219-1803 | Implement Excel Import Service

**Architecture / Design (if applicable):**
- Introduce an import service boundary responsible for file parsing, header validation, row mapping, and structured import reporting.
- Keep source column contracts centralized to avoid scattering schema rules.

**Business Logic (if applicable):**
- Parse account/amount/date from exact headers only; normalize dates to day precision.
- Ignore non-required columns when required headers are present.
- Skip malformed rows and surface them in an import report without stopping valid-row ingestion.

---

## 20260219-2100 | Implement Reconciliation Engine

**Architecture / Design:**
- New service boundary: `ReconciliationService` under `application/services/`, takes two `List<TransactionRecord>` and returns `ReconciliationReport`.
- New model: `ReconciliationReport` under `application/models/`, mirrors `ImportReport` pattern with result list and precomputed summary counts.
- Matching priority: full match phase runs first and claims records; partial match phase operates only on unclaimed records.

**Business Logic:**
- Full match: identical account + normalized amount + date; one-to-one enforced.
- Partial match: identical account + normalized amount, different date; all candidate pairs surfaced (no claiming).
- Unmatched bank: bank record with no full match and no partial match candidates.
- Unmatched platform: platform record not claimed by full match and not surfaced in any partial match.

---
