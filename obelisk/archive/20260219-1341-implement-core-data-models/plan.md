# Plan: Implement Core Data Models

## Goal
Implement the `TransactionRecord` and `ReconciliationResult` data models, handling 3-decimal precision logic as requested.

## Scope Boundaries
✓ In scope:
- `lib/features/transactions/domain/transaction_record.dart`
- `lib/features/transactions/domain/reconciliation_result.dart`
- Enum definitions: `TransactionSource`, `ReconciliationStatus`
- 3-decimal precision logic in `operator ==` and `hashCode`

✗ Out of scope:
- Any other directories.
- Tests (unless specifically requested or following test-driven if applicable, but per guidelines: "Do not add tests unless explicitly requested").

---

## Relevant Contracts

- **Input Contract** — Must support structure derived from Bank/Platform excel files.
- **Matching Contract** — Equality logic must support 3-decimal precision matching.
- **Precision** — 3 decimal digits, no epsilon (exact).

---

## Relevant Design Constraints

- **Structure** — Feature-first (`lib/features/transactions/domain/`).
- **Immutability** — All models must be immutable.
- **No Dependencies** — Use pure Dart only.

---

## Execution Strategy
1.  Check for existence of `lib/features/transactions/domain/` directory, create if missing.
2.  Implement `TransactionRecord` class with fields: `date`, `amount` (double), `account` (String normalized), `source`.
    -   Implement manual `==` and `hashCode` focusing on `amount` rounded to 3 decimals.
    -   Add `toString()` for debugging.
3.  Implement `ReconciliationResult` class with fields: `status`, `bankRecord`, `platformRecord`.
    -   Implement manual `==` and `hashCode`.
    -   Add `toString()`.
4.  Verify implementation by checking code structure (visual inspection).

---

## Affected Files

- `/lib/features/transactions/domain/transaction_record.dart` — [NEW] Core model.
- `/lib/features/transactions/domain/reconciliation_result.dart` — [NEW] Result model.
