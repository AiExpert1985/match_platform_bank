import 'dart:io';

import 'package:excel/excel.dart';
import 'package:match_platform_bank/features/transactions/application/models/import_report.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';

class ExcelImportService {
  static const _bankSchema = _SheetSchema(
    accountHeader: 'ACCOUNT_NO',
    amountHeader: 'NET',
    dateHeader: 'Transaction Date',
  );

  static const _platformSchema = _SheetSchema(
    accountHeader: '\u0631\u0642\u0645 \u0627\u0644\u062d\u0633\u0627\u0628',
    amountHeader:
        '\u0627\u0644\u0645\u0628\u0644\u063a \u0628\u0639\u062f \u0627\u0644\u062e\u0635\u0645',
    dateHeader:
        '\u062a\u0627\u0631\u064a\u062e \u0627\u0644\u0639\u0645\u0644\u064a\u0629',
  );

  Future<ImportReport> importFromFile({
    required String filePath,
    required TransactionSource source,
  }) async {
    if (!_isExcelPath(filePath)) {
      return ImportReport(
        source: source,
        records: const [],
        issues: const [
          ImportIssue(
            type: ImportIssueType.invalidFile,
            message: 'Only .xlsx files are supported.',
          ),
        ],
        missingHeaders: const [],
        totalDataRows: 0,
      );
    }

    final fileBytes = await File(filePath).readAsBytes();
    return importFromBytes(bytes: fileBytes, source: source);
  }

  ImportReport importFromBytes({
    required List<int> bytes,
    required TransactionSource source,
  }) {
    if (bytes.isEmpty) {
      return ImportReport(
        source: source,
        records: const [],
        issues: const [
          ImportIssue(
            type: ImportIssueType.invalidFile,
            message: 'Excel file is empty.',
          ),
        ],
        missingHeaders: const [],
        totalDataRows: 0,
      );
    }

    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      return ImportReport(
        source: source,
        records: const [],
        issues: const [
          ImportIssue(
            type: ImportIssueType.invalidFile,
            message: 'No worksheets found in the Excel file.',
          ),
        ],
        missingHeaders: const [],
        totalDataRows: 0,
      );
    }

    final sheet = workbook.tables.values.first;
    final rows = sheet.rows;
    if (rows.isEmpty) {
      return ImportReport(
        source: source,
        records: const [],
        issues: const [
          ImportIssue(
            type: ImportIssueType.invalidFile,
            message: 'Worksheet does not contain any rows.',
          ),
        ],
        missingHeaders: const [],
        totalDataRows: 0,
      );
    }

    final schema = _schemaFor(source);
    final headerIndexByName = _extractHeaderIndices(rows.first);
    final missingHeaders = schema.requiredHeaders
        .where((header) => !headerIndexByName.containsKey(header))
        .toList(growable: false);

    if (missingHeaders.isNotEmpty) {
      return ImportReport(
        source: source,
        records: const [],
        issues: [
          ImportIssue(
            type: ImportIssueType.missingHeaders,
            message: 'Missing required headers: ${missingHeaders.join(', ')}',
          ),
        ],
        missingHeaders: missingHeaders,
        totalDataRows: rows.length > 1 ? rows.length - 1 : 0,
      );
    }

    final accountColumnIndex = headerIndexByName[schema.accountHeader]!;
    final amountColumnIndex = headerIndexByName[schema.amountHeader]!;
    final dateColumnIndex = headerIndexByName[schema.dateHeader]!;

    final uniqueRecords = <TransactionRecord>{};
    final issues = <ImportIssue>[];

    for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final rowNumber = rowIndex + 1;

      final accountValue = _cellValueAt(row, accountColumnIndex);
      final amountValue = _cellValueAt(row, amountColumnIndex);
      final dateValue = _cellValueAt(row, dateColumnIndex);

      if (_isRowFullyEmpty(accountValue, amountValue, dateValue)) {
        continue;
      }

      final account = _parseAccount(accountValue);
      final amount = _parseAmount(amountValue);
      final date = _parseDateOnly(dateValue);

      if (account == null || amount == null || date == null) {
        final invalidFields = <String>[];
        if (account == null) invalidFields.add('account');
        if (amount == null) invalidFields.add('amount');
        if (date == null) invalidFields.add('date');

        issues.add(
          ImportIssue(
            type: ImportIssueType.invalidRow,
            rowNumber: rowNumber,
            message: 'Invalid ${invalidFields.join(', ')} value.',
          ),
        );
        continue;
      }

      final record = TransactionRecord(
        date: date,
        amount: amount,
        account: account,
        source: source,
      );

      // Deduplicate identical rows within the same source file.
      if (!uniqueRecords.add(record)) {
        issues.add(
          ImportIssue(
            type: ImportIssueType.duplicateRow,
            rowNumber: rowNumber,
            message: 'Duplicate row ignored.',
          ),
        );
      }
    }

    return ImportReport(
      source: source,
      records: uniqueRecords.toList(growable: false),
      issues: issues,
      missingHeaders: const [],
      totalDataRows: rows.length > 1 ? rows.length - 1 : 0,
    );
  }

  bool _isExcelPath(String filePath) {
    return filePath.toLowerCase().endsWith('.xlsx');
  }

  _SheetSchema _schemaFor(TransactionSource source) {
    return switch (source) {
      TransactionSource.bank => _bankSchema,
      TransactionSource.platform => _platformSchema,
    };
  }

  Map<String, int> _extractHeaderIndices(List<Data?> headerRow) {
    final headerIndexByName = <String, int>{};
    for (var index = 0; index < headerRow.length; index++) {
      final rawHeader = _cellValueToString(headerRow[index]?.value);
      if (rawHeader == null || rawHeader.isEmpty) {
        continue;
      }

      if (!headerIndexByName.containsKey(rawHeader)) {
        headerIndexByName[rawHeader] = index;
      }
    }
    return headerIndexByName;
  }

  CellValue? _cellValueAt(List<Data?> row, int columnIndex) {
    if (columnIndex >= row.length) {
      return null;
    }
    return row[columnIndex]?.value;
  }

  bool _isRowFullyEmpty(
    CellValue? accountValue,
    CellValue? amountValue,
    CellValue? dateValue,
  ) {
    return _cellValueToString(accountValue) == null &&
        _cellValueToString(amountValue) == null &&
        _cellValueToString(dateValue) == null;
  }

  String? _parseAccount(CellValue? value) {
    final raw = _cellValueToString(value);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return _normalizeAccount(raw);
  }

  /// Strips leading zeros from purely-numeric account strings so that bank
  /// integer cells (e.g. 12345) and platform text cells (e.g. "012345") match.
  String _normalizeAccount(String raw) {
    if (!RegExp(r'^\d+$').hasMatch(raw)) return raw;
    final stripped = raw.replaceFirst(RegExp(r'^0+'), '');
    return stripped.isEmpty ? '0' : stripped;
  }

  double? _parseAmount(CellValue? value) {
    if (value == null) {
      return null;
    }

    final double? parsed;
    if (value is IntCellValue) {
      parsed = value.value.toDouble();
    } else if (value is DoubleCellValue) {
      parsed = value.value;
    } else if (value is TextCellValue) {
      parsed = double.tryParse(
        value.value.toString().replaceAll(',', '').trim(),
      );
    } else {
      parsed = null;
    }

    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return null;
    }
    return parsed;
  }

  DateTime? _parseDateOnly(CellValue? value) {
    if (value == null) {
      return null;
    }

    final DateTime? parsedDate;
    if (value is DateCellValue) {
      parsedDate = value.asDateTimeLocal();
    } else if (value is DateTimeCellValue) {
      parsedDate = value.asDateTimeLocal();
    } else if (value is IntCellValue) {
      parsedDate = _excelSerialToDate(value.value.toDouble());
    } else if (value is DoubleCellValue) {
      parsedDate = _excelSerialToDate(value.value);
    } else if (value is TextCellValue) {
      parsedDate = _parseTextDate(value.value.toString());
    } else {
      parsedDate = null;
    }

    if (parsedDate == null) {
      return null;
    }

    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
  }

  DateTime? _excelSerialToDate(double serialValue) {
    if (serialValue.isNaN || serialValue.isInfinite || serialValue <= 0) {
      return null;
    }

    final days = serialValue.floor();
    return DateTime(1899, 12, 30).add(Duration(days: days));
  }

  DateTime? _parseTextDate(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final isoParsed = DateTime.tryParse(trimmed);
    if (isoParsed != null) {
      return isoParsed;
    }

    // Strip optional time + AM/PM suffix (e.g. "01/02/2026 12:28:02 م" → "01/02/2026").
    final datePart = trimmed.split(' ').first;
    final slashDateMatch = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(datePart);
    if (slashDateMatch == null) {
      return null;
    }

    final first = int.tryParse(slashDateMatch.group(1)!);
    final second = int.tryParse(slashDateMatch.group(2)!);
    final year = int.tryParse(slashDateMatch.group(3)!);
    if (first == null || second == null || year == null) {
      return null;
    }

    final monthFirst = _tryBuildDate(year, first, second);
    if (monthFirst != null) {
      return monthFirst;
    }

    return _tryBuildDate(year, second, first);
  }

  DateTime? _tryBuildDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    final candidate = DateTime(year, month, day);
    if (candidate.year != year ||
        candidate.month != month ||
        candidate.day != day) {
      return null;
    }
    return candidate;
  }

  String? _cellValueToString(CellValue? value) {
    if (value == null) {
      return null;
    }

    final String text;
    if (value is TextCellValue) {
      text = value.value.toString().trim();
    } else if (value is IntCellValue) {
      text = value.value.toString();
    } else if (value is DoubleCellValue) {
      text = value.value % 1 == 0
          ? value.value.toInt().toString()
          : value.value.toString();
    } else if (value is BoolCellValue) {
      text = value.value.toString();
    } else if (value is DateCellValue) {
      text = value.asDateTimeLocal().toIso8601String();
    } else if (value is DateTimeCellValue) {
      text = value.asDateTimeLocal().toIso8601String();
    } else {
      text = value.toString().trim();
    }

    return text.isEmpty ? null : text;
  }
}

class _SheetSchema {
  final String accountHeader;
  final String amountHeader;
  final String dateHeader;

  const _SheetSchema({
    required this.accountHeader,
    required this.amountHeader,
    required this.dateHeader,
  });

  List<String> get requiredHeaders => [accountHeader, amountHeader, dateHeader];
}
