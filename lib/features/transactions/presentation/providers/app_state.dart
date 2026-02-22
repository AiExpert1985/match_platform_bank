import 'package:match_platform_bank/features/transactions/application/models/import_report.dart';
import 'package:match_platform_bank/features/transactions/application/models/reconciliation_report.dart';

sealed class ImportState {
  const ImportState();
}

class ImportIdle extends ImportState {
  const ImportIdle();
}

class ImportLoading extends ImportState {
  const ImportLoading();
}

class ImportSuccess extends ImportState {
  final ImportReport report;
  const ImportSuccess(this.report);
}

class ImportFailure extends ImportState {
  final String message;
  const ImportFailure(this.message);
}

sealed class ReconciliationState {
  const ReconciliationState();
}

class ReconciliationIdle extends ReconciliationState {
  const ReconciliationIdle();
}

class ReconciliationSuccess extends ReconciliationState {
  final ReconciliationReport report;
  const ReconciliationSuccess(this.report);
}

class ReconciliationFailure extends ReconciliationState {
  final String message;
  const ReconciliationFailure(this.message);
}

class AppState {
  final ImportState bankImport;
  final ImportState platformImport;
  final ReconciliationState reconciliation;

  const AppState({
    this.bankImport = const ImportIdle(),
    this.platformImport = const ImportIdle(),
    this.reconciliation = const ReconciliationIdle(),
  });

  AppState copyWith({
    ImportState? bankImport,
    ImportState? platformImport,
    ReconciliationState? reconciliation,
  }) {
    return AppState(
      bankImport: bankImport ?? this.bankImport,
      platformImport: platformImport ?? this.platformImport,
      reconciliation: reconciliation ?? this.reconciliation,
    );
  }
}
