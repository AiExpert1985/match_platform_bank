import 'package:match_platform_bank/features/transactions/application/models/reconciliation_report.dart';
import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';

class ReconciliationService {
  ReconciliationReport reconcile({
    required List<TransactionRecord> bankRecords,
    required List<TransactionRecord> platformRecords,
  }) {
    final results = <ReconciliationResult>[];
    final claimedBank = <TransactionRecord>{};
    final claimedPlatform = <TransactionRecord>{};

    // Phase 1: Full matches — one-to-one enforced.
    final platformByFullKey = _groupByKey(platformRecords, _fullKey);
    for (final bank in bankRecords) {
      final candidates = platformByFullKey[_fullKey(bank)];
      if (candidates != null && candidates.isNotEmpty) {
        final platform = candidates.removeAt(0);
        claimedBank.add(bank);
        claimedPlatform.add(platform);
        results.add(ReconciliationResult(
          status: ReconciliationStatus.fullMatch,
          bankRecord: bank,
          platformRecord: platform,
        ));
      }
    }

    final unclaimedBank =
        bankRecords.where((b) => !claimedBank.contains(b)).toList();
    final unclaimedPlatform =
        platformRecords.where((p) => !claimedPlatform.contains(p)).toList();

    // Phases 2–4: Account-based matching with subcategories.
    // No claiming: all candidate pairs are surfaced.
    final platformByAccount = _groupByKey(unclaimedPlatform, (r) => r.account);
    final surfacedPlatform = <TransactionRecord>{};

    for (final bank in unclaimedBank) {
      final candidates = platformByAccount[bank.account] ?? [];
      var hasCandidates = false;

      for (final platform in candidates) {
        final sameAmount =
            _normalizeAmount(bank.amount) == _normalizeAmount(platform.amount);
        final sameDate = bank.date == platform.date;

        final status = sameAmount
            ? ReconciliationStatus.differentDate
            : sameDate
                ? ReconciliationStatus.differentAmount
                : ReconciliationStatus.differentDateAndAmount;

        hasCandidates = true;
        surfacedPlatform.add(platform);
        results.add(ReconciliationResult(
          status: status,
          bankRecord: bank,
          platformRecord: platform,
        ));
      }

      if (!hasCandidates) {
        results.add(ReconciliationResult(
          status: ReconciliationStatus.bankOnly,
          bankRecord: bank,
          platformRecord: null,
        ));
      }
    }

    // Phase 5: Unmatched platform records.
    for (final platform in unclaimedPlatform) {
      if (!surfacedPlatform.contains(platform)) {
        results.add(ReconciliationResult(
          status: ReconciliationStatus.platformOnly,
          bankRecord: null,
          platformRecord: platform,
        ));
      }
    }

    return ReconciliationReport(results: results);
  }

  Map<String, List<TransactionRecord>> _groupByKey(
    List<TransactionRecord> records,
    String Function(TransactionRecord) keyFn,
  ) {
    final map = <String, List<TransactionRecord>>{};
    for (final record in records) {
      (map[keyFn(record)] ??= []).add(record);
    }
    return map;
  }

  String _fullKey(TransactionRecord record) {
    return '${record.account}|${_normalizeAmount(record.amount)}|${record.date.millisecondsSinceEpoch}';
  }

  double _normalizeAmount(double amount) {
    return (amount * 1000).roundToDouble() / 1000;
  }
}
