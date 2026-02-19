import 'package:file_picker/file_picker.dart';
import 'package:match_platform_bank/features/transactions/application/models/import_report.dart';
import 'package:match_platform_bank/features/transactions/application/services/excel_import_service.dart';
import 'package:match_platform_bank/features/transactions/application/services/reconciliation_service.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_notifier.g.dart';

final _importService = ExcelImportService();
final _reconciliationService = ReconciliationService();

@riverpod
class AppNotifier extends _$AppNotifier {
  @override
  AppState build() => const AppState();

  Future<void> importFile(TransactionSource source) async {
    _setImportState(source, const ImportLoading());

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) {
      _setImportState(source, const ImportIdle());
      return;
    }

    final path = result.files.single.path;
    if (path == null) {
      _setImportState(source, const ImportFailure('لم يتم تحديد الملف.'));
      return;
    }

    try {
      final report = await _importService.importFromFile(
        filePath: path,
        source: source,
      );

      if (_isCriticalFailure(report)) {
        _setImportState(source, const ImportFailure('فشل الاستيراد.'));
      } else {
        _setImportState(source, ImportSuccess(report));
      }
    } catch (_) {
      _setImportState(source, const ImportFailure('فشل الاستيراد.'));
    }
  }

  void reconcile() {
    final bankState = state.bankImport;
    final platformState = state.platformImport;
    if (bankState is! ImportSuccess || platformState is! ImportSuccess) return;

    try {
      final report = _reconciliationService.reconcile(
        bankRecords: bankState.report.records,
        platformRecords: platformState.report.records,
      );
      state = state.copyWith(reconciliation: ReconciliationSuccess(report));
    } catch (_) {
      state = state.copyWith(
        reconciliation: const ReconciliationFailure('فشلت عملية المطابقة.'),
      );
    }
  }

  bool _isCriticalFailure(ImportReport report) {
    return report.hasMissingHeaders ||
        report.issues.any((i) => i.type == ImportIssueType.invalidFile);
  }

  void _setImportState(TransactionSource source, ImportState importState) {
    if (source == TransactionSource.bank) {
      state = state.copyWith(bankImport: importState);
    } else {
      state = state.copyWith(platformImport: importState);
    }
  }
}
