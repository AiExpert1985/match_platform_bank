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
