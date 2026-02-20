import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';

class ReconciliationReport {
  final List<ReconciliationResult> results;

  const ReconciliationReport({required this.results});

  int get fullMatchCount =>
      results.where((r) => r.status == ReconciliationStatus.fullMatch).length;

  int get differentDateCount =>
      results.where((r) => r.status == ReconciliationStatus.differentDate).length;

  int get differentAmountCount =>
      results
          .where((r) => r.status == ReconciliationStatus.differentAmount)
          .length;

  int get differentDateAndAmountCount =>
      results
          .where((r) => r.status == ReconciliationStatus.differentDateAndAmount)
          .length;

  int get unmatchedBankCount =>
      results.where((r) => r.status == ReconciliationStatus.bankOnly).length;

  int get unmatchedPlatformCount =>
      results.where((r) => r.status == ReconciliationStatus.platformOnly).length;
}
