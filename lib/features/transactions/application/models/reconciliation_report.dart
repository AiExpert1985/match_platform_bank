import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';

class ReconciliationReport {
  final List<ReconciliationResult> results;

  const ReconciliationReport({required this.results});

  int get fullMatchCount =>
      results.where((r) => r.status == ReconciliationStatus.fullMatch).length;

  int get partialMatchCount =>
      results.where((r) => r.status == ReconciliationStatus.partialMatch).length;

  int get unmatchedBankCount => results
      .where(
        (r) =>
            r.status == ReconciliationStatus.unmatched && r.bankRecord != null,
      )
      .length;

  int get unmatchedPlatformCount => results
      .where(
        (r) =>
            r.status == ReconciliationStatus.unmatched &&
            r.platformRecord != null,
      )
      .length;
}
