# Contracts Summary

Generated: 2026-02-19

## System Identity
_(empty — populated after first maintenance)_

## Active Contracts
_(empty — populated after first maintenance)_

## Non-Goals
_(empty — populated after first maintenance)_


## Unprocessed

## 20260219-1341 | Implement Core Data Models

- **Precision**: Monetary comparison uses 3-decimal digit precision (represented as double).

---

- **System Identity:** Single-screen desktop application for reconciling Bank vs Platform records.
- **Core Invariant**: Application is stateless; all data exists in memory only. No persistence between sessions.
- **Input Contract**: Accepts two Excel (.xlsx) files (Bank, Platform) with specific (configurable) headers.
- **Matching Contract**: One-to-one matching enforced. A record can match exactly one other record or none.
- **Matching Types**: 
    1. **Full Match**: Identical Account, Amount, and Date.
    2. **Partial Match**: Identical Account and Amount, different Date.
    3. **Unmatched**: No match found in the other file.
- **Deduplication**: Identical records within a single file are treated as a single entry (duplicates ignored).
- **Precision**: Monetary comparison uses exact precision (no epsilon).
- **Safety**: Read-only operation. No editing, deleting, or adding records allowed.
- **Non-Goal**: Historical tracking or database storage.

## 20260219-2100 | Implement Reconciliation Engine

**Action:** update
**Change:**
- "One-to-one matching enforced. A record can match exactly one other record or none." →
  One-to-one applies **only to full matches**. For partial matches, all ambiguous candidate pairs are surfaced as separate result rows.

---
