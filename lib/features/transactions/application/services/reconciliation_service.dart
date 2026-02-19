import 'package:match_platform_bank/features/transactions/application/models/reconciliation_report.dart';
import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';

class ReconciliationService {
  ReconciliationReport reconcile({
    required List<TransactionRecord> bankRecords,
    required List<TransactionRecord> platformRecords,
  }) {
    final results = <ReconciliationResult>[];
    final claimedPlatformRecords = <TransactionRecord>{};
    final unmatchedBankRecords = <TransactionRecord>[];

    // Phase 1: Full matches — one-to-one enforced.
    final platformByFullKey = _groupByFullKey(platformRecords);
    for (final bank in bankRecords) {
      final candidates = platformByFullKey[_fullKey(bank)];
      if (candidates != null && candidates.isNotEmpty) {
        final platform = candidates.removeAt(0);
        claimedPlatformRecords.add(platform);
        results.add(ReconciliationResult(
          status: ReconciliationStatus.fullMatch,
          bankRecord: bank,
          platformRecord: platform,
        ));
      } else {
        unmatchedBankRecords.add(bank);
      }
    }

    // Phase 2 & 3: Partial matches and unmatched bank records.
    final platformByPartialKey =
        _groupByPartialKey(platformRecords, claimedPlatformRecords);
    final surfacedPlatformRecords = <TransactionRecord>{};

    for (final bank in unmatchedBankRecords) {
      final candidates = (platformByPartialKey[_partialKey(bank)] ?? [])
          .where((p) => p.date != bank.date)
          .toList();

      if (candidates.isNotEmpty) {
        for (final platform in candidates) {
          surfacedPlatformRecords.add(platform);
          results.add(ReconciliationResult(
            status: ReconciliationStatus.partialMatch,
            bankRecord: bank,
            platformRecord: platform,
          ));
        }
      } else {
        results.add(ReconciliationResult(
          status: ReconciliationStatus.unmatched,
          bankRecord: bank,
          platformRecord: null,
        ));
      }
    }

    // Phase 4: Unmatched platform records.
    for (final platform in platformRecords) {
      if (!claimedPlatformRecords.contains(platform) &&
          !surfacedPlatformRecords.contains(platform)) {
        results.add(ReconciliationResult(
          status: ReconciliationStatus.unmatched,
          bankRecord: null,
          platformRecord: platform,
        ));
      }
    }

    return ReconciliationReport(results: results);
  }

  Map<String, List<TransactionRecord>> _groupByFullKey(
    List<TransactionRecord> records,
  ) {
    final map = <String, List<TransactionRecord>>{};
    for (final record in records) {
      (map[_fullKey(record)] ??= []).add(record);
    }
    return map;
  }

  Map<String, List<TransactionRecord>> _groupByPartialKey(
    List<TransactionRecord> records,
    Set<TransactionRecord> claimed,
  ) {
    final map = <String, List<TransactionRecord>>{};
    for (final record in records) {
      if (claimed.contains(record)) continue;
      (map[_partialKey(record)] ??= []).add(record);
    }
    return map;
  }

  String _fullKey(TransactionRecord record) {
    return '${record.account}|${_normalizeAmount(record.amount)}|${record.date.millisecondsSinceEpoch}';
  }

  String _partialKey(TransactionRecord record) {
    return '${record.account}|${_normalizeAmount(record.amount)}';
  }

  double _normalizeAmount(double amount) {
    return (amount * 1000).roundToDouble() / 1000;
  }
}
