import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';

enum ReconciliationStatus {
  fullMatch,
  differentDate,
  differentAmount,
  differentDateAndAmount,
  bankOnly,
  platformOnly,
}

class ReconciliationResult {
  final ReconciliationStatus status;
  final TransactionRecord? bankRecord;
  final TransactionRecord? platformRecord;

  const ReconciliationResult({
    required this.status,
    this.bankRecord,
    this.platformRecord,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReconciliationResult &&
        other.status == status &&
        other.bankRecord == bankRecord &&
        other.platformRecord == platformRecord;
  }

  @override
  int get hashCode {
    return status.hashCode ^ bankRecord.hashCode ^ platformRecord.hashCode;
  }

  @override
  String toString() {
    return 'ReconciliationResult(status: $status, bankRecord: $bankRecord, platformRecord: $platformRecord)';
  }
}
