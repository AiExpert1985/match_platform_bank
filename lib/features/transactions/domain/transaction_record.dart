enum TransactionSource { bank, platform }

class TransactionRecord {
  final DateTime date;
  final double amount;
  final String account;
  final TransactionSource source;

  const TransactionRecord({
    required this.date,
    required this.amount,
    required this.account,
    required this.source,
  });

  /// Rounds the amount to 3 decimal places for comparison.
  ///
  /// Multiplies by 1000, rounds to nearest integer, then divides by 1000.
  double get _normalizedAmount {
    return (amount * 1000).roundToDouble() / 1000;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionRecord &&
        other.date == date &&
        other._normalizedAmount == _normalizedAmount &&
        other.account == account &&
        other.source == source;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        _normalizedAmount.hashCode ^
        account.hashCode ^
        source.hashCode;
  }

  @override
  String toString() {
    return 'TransactionRecord(date: $date, amount: $amount, account: $account, source: $source)';
  }
}
