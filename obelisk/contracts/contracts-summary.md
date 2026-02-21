# Contracts Summary

Generated: 2026-02-21

## System Identity

Single-screen desktop application for reconciling Bank vs Platform transaction records.

## Active Contracts

**Statelessness**
All data exists in memory only. No persistence between sessions.

**Input**
Accepts two Excel (.xlsx) files (Bank, Platform) with specific, configurable column headers.

**Safety**
Read-only operation. No editing, deleting, or adding of records is permitted.

**Deduplication**
Identical records within a single file (same account + amount + date) are treated as one entry. Applied per-file at import time.

**Matching Algorithm** _(authoritative as of 20260220-1700)_
1. Account-level split: bank records whose account does not appear in any platform record → Bank Only; platform records whose account does not appear in any bank record → Platform Only.
2. Cross-file pairing: for each account present in both files, every bank record with that account is paired with every platform record with that account (cartesian product).
3. Each pair is independently assigned a status:
   - Same amount AND same date → **Full Match**
   - Same amount, different date → **Different Date**
   - Same date, different amount → **Different Amount**
   - Different date AND different amount → **Different Date and Amount**
4. No record is claimed; a single record may appear in multiple result rows.

**Precision**
⚠️ Conflict — see Open Contract Questions.

## Non-Goals

- Historical tracking or database storage.

## Open Contract Questions

**Precision conflict (20260219-1341):** Two contradictory statements in the same log entry:
1. "Monetary comparison uses 3-decimal digit precision (represented as double)."
2. "Monetary comparison uses exact precision (no epsilon)."
Both retained until explicitly resolved.

## Unprocessed
