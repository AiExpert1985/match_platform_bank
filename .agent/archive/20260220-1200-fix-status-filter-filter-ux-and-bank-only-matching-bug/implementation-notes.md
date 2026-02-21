# Implementation Notes: Fix Status Filter, Filter UX, and Bank-Only Matching Bug

## Execution Summary
All plan steps implemented as specified across four files.

## Divergences

- Plan specified: `_StatusFilter._options` as `static final`.
  Actual: kept as `static final` (unchanged from original — no divergence).

- Plan specified: account normalization in `_parseAccount`.
  Actual: added a private `_normalizeAccount` helper method in `ExcelImportService` rather than inlining in `_parseAccount`, to keep each method single-responsibility. Mechanically necessary per ai-engineering guidelines (single responsibility, ~20–30 lines).

- Plan specified: "Add 'الكل' as first item in dialog; selecting it clears all others."
  Actual: Also removed the now-redundant "إلغاء الكل" action button from the dialog, since the "الكل" checkbox fulfils the same role. Single "تطبيق" button remains. Mechanically consistent with the intent (no duplicate clear mechanism).
