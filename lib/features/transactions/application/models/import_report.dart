import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';

enum ImportIssueType { invalidFile, missingHeaders, invalidRow, duplicateRow }

class ImportIssue {
  final ImportIssueType type;
  final int? rowNumber;
  final String message;

  const ImportIssue({
    required this.type,
    required this.message,
    this.rowNumber,
  });
}

class ImportReport {
  final TransactionSource source;
  final List<TransactionRecord> records;
  final List<ImportIssue> issues;
  final List<String> missingHeaders;
  final int totalDataRows;

  const ImportReport({
    required this.source,
    required this.records,
    required this.issues,
    required this.missingHeaders,
    required this.totalDataRows,
  });

  bool get hasMissingHeaders => missingHeaders.isNotEmpty;

  int get importedRows => records.length;

  int get skippedRows =>
      issues.where((issue) => issue.rowNumber != null).length;
}
