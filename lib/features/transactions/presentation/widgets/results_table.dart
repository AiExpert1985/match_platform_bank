import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_notifier.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_state.dart';

class ResultsTable extends ConsumerWidget {
  const ResultsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(
      appProvider.select((s) => s.reconciliation),
    );

    return switch (reconciliation) {
      ReconciliationIdle() => const SizedBox.shrink(),
      ReconciliationFailure(:final message) => Center(child: Text(message)),
      ReconciliationSuccess(:final report) => _Table(results: report.results),
    };
  }
}

class _Table extends StatelessWidget {
  final List<ReconciliationResult> results;

  const _Table({required this.results});

  @override
  Widget build(BuildContext context) {
    final rows = _filteredAndSorted(results);

    if (rows.isEmpty) {
      return const Center(child: Text('لا توجد نتائج.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('رقم الحساب\n(المنصة)')),
            DataColumn(label: Text('المبلغ\n(المنصة)')),
            DataColumn(label: Text('التاريخ\n(المنصة)')),
            DataColumn(label: Text('رقم الحساب\n(البنك)')),
            DataColumn(label: Text('المبلغ\n(البنك)')),
            DataColumn(label: Text('التاريخ\n(البنك)')),
            DataColumn(label: Text('الحالة')),
          ],
          rows: rows.map(_buildRow).toList(),
        ),
      ),
    );
  }

  List<ReconciliationResult> _filteredAndSorted(
    List<ReconciliationResult> results,
  ) {
    final filtered = results
        .where((r) => r.status != ReconciliationStatus.fullMatch)
        .toList();
    filtered.sort((a, b) => _sortOrder(a).compareTo(_sortOrder(b)));
    return filtered;
  }

  int _sortOrder(ReconciliationResult r) {
    if (r.status == ReconciliationStatus.partialMatch) return 0;
    if (r.bankRecord != null) return 1; // unmatched bank
    return 2; // unmatched platform
  }

  DataRow _buildRow(ReconciliationResult result) {
    final p = result.platformRecord;
    final b = result.bankRecord;

    return DataRow(
      cells: [
        DataCell(Text(p?.account ?? '')),
        DataCell(Text(p != null ? _formatAmount(p.amount) : '')),
        DataCell(Text(p != null ? _formatDate(p.date) : '')),
        DataCell(Text(b?.account ?? '')),
        DataCell(Text(b != null ? _formatAmount(b.amount) : '')),
        DataCell(Text(b != null ? _formatDate(b.date) : '')),
        DataCell(Text(_statusLabel(result))),
      ],
    );
  }

  String _formatAmount(double amount) {
    final rounded = (amount * 1000).round() / 1000;
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toInt().toString();
    }
    final s = rounded.toStringAsFixed(3);
    final trimmed = s.replaceAll(RegExp(r'0+$'), '');
    return trimmed.endsWith('.') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}/$m/$d';
  }

  String _statusLabel(ReconciliationResult r) {
    return switch (r.status) {
      ReconciliationStatus.partialMatch => 'تطابق جزئي',
      ReconciliationStatus.unmatched when r.bankRecord != null => 'بنك فقط',
      ReconciliationStatus.unmatched => 'منصة فقط',
      ReconciliationStatus.fullMatch => '',
    };
  }
}
