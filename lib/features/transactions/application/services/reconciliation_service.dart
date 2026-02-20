import 'package:match_platform_bank/features/transactions/application/models/reconciliation_report.dart';
import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';

class ReconciliationService {
  ReconciliationReport reconcile({
    required List<TransactionRecord> bankRecords,
    required List<TransactionRecord> platformRecords,
  }) {
    final results = <ReconciliationResult>[];

    final bankAccounts = bankRecords.map((r) => r.account).toSet();
    final platformAccounts = platformRecords.map((r) => r.account).toSet();

    // Platform-only: account not present in any bank record.
    for (final platform in platformRecords) {
      if (!bankAccounts.contains(platform.account)) {
        results.add(ReconciliationResult(
          status: ReconciliationStatus.platformOnly,
          bankRecord: null,
          platformRecord: platform,
        ));
      }
    }

    // Bank-only: account not present in any platform record.
    for (final bank in bankRecords) {
      if (!platformAccounts.contains(bank.account)) {
        results.add(ReconciliationResult(
          status: ReconciliationStatus.bankOnly,
          bankRecord: bank,
          platformRecord: null,
        ));
      }
    }

    // Cross-file pairs: cartesian product within each shared account group.
    final bankByAccount = _groupByAccount(bankRecords);
    final platformByAccount = _groupByAccount(platformRecords);

    for (final account in bankAccounts.intersection(platformAccounts)) {
      final bankGroup = bankByAccount[account]!;
      final platformGroup = platformByAccount[account]!;

      for (final bank in bankGroup) {
        for (final platform in platformGroup) {
          final sameAmount =
              _normalizeAmount(bank.amount) == _normalizeAmount(platform.amount);
          final sameDate = bank.date == platform.date;

          final status = sameAmount && sameDate
              ? ReconciliationStatus.fullMatch
              : sameAmount
                  ? ReconciliationStatus.differentDate
                  : sameDate
                      ? ReconciliationStatus.differentAmount
                      : ReconciliationStatus.differentDateAndAmount;

          results.add(ReconciliationResult(
            status: status,
            bankRecord: bank,
            platformRecord: platform,
          ));
        }
      }
    }

    return ReconciliationReport(results: results);
  }

  Map<String, List<TransactionRecord>> _groupByAccount(
    List<TransactionRecord> records,
  ) {
    final map = <String, List<TransactionRecord>>{};
    for (final record in records) {
      (map[record.account] ??= []).add(record);
    }
    return map;
  }

  double _normalizeAmount(double amount) {
    return (amount * 1000).roundToDouble() / 1000;
  }
}
