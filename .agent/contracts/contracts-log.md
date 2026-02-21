# Contracts Log

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

## 20260220-0000 | Expand Matching Logic, Add Column Filters, and UI Polish

**Action:** update
**Change:**
- "Matching Types: 2. Partial Match: Identical Account and Amount, different Date." →
  Remove "Partial Match" and replace with three subcategories:
  2. **Different Date**: Identical Account and Amount, different Date.
  3. **Different Amount**: Identical Account and Date, different Amount.
  4. **Different Date and Amount**: Identical Account only (Amount and Date both differ).

---

## 20260220-1700 | Fix Matching Algorithm and Show All Statuses

**Action:** update
**Change:**
- Replace "One-to-one applies only to full matches. For partial matches, all ambiguous candidate pairs are surfaced as separate result rows." with:
  **Matching Algorithm (authoritative):**
  1. Deduplication is applied per-file at import time (same account + amount + date = one entry).
  2. Account-level split: platform records whose account does not appear in any bank record → Platform Only; bank records whose account does not appear in any platform record → Bank Only.
  3. Cross-file pairing: for each account number present in both files, every bank record with that account is paired with every platform record with that account (cartesian product). Each pair is independently assigned a status:
     - Same amount AND same date → Full Match
     - Same amount, different date → Different Date
     - Same date, different amount → Different Amount
     - Different date AND different amount → Different Date and Amount
  4. No record is claimed; a single record may appear in multiple result rows.

---
