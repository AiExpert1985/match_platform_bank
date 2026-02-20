import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match_platform_bank/features/transactions/domain/reconciliation_result.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_notifier.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_state.dart';

const _colAccount = 160.0;
const _colAmount = 120.0;
const _colDate = 110.0;
const _colStatus = 200.0;
const _totalWidth =
    _colAccount * 2 + _colAmount * 2 + _colDate * 2 + _colStatus;

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

class _Table extends StatefulWidget {
  final List<ReconciliationResult> results;

  const _Table({required this.results});

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  final _platformAccountCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _platformAmountCtrl = TextEditingController();
  final _bankAmountCtrl = TextEditingController();
  DateTime? _platformDate;
  DateTime? _bankDate;
  Set<ReconciliationStatus> _selectedStatuses = {};
  String _platformAmountFilter = '';
  String _bankAmountFilter = '';

  @override
  void dispose() {
    _platformAccountCtrl.dispose();
    _bankAccountCtrl.dispose();
    _platformAmountCtrl.dispose();
    _bankAmountCtrl.dispose();
    super.dispose();
  }

  List<ReconciliationResult> _sort(List<ReconciliationResult> input) {
    final rows = input
        .where((r) => r.status != ReconciliationStatus.fullMatch)
        .toList()
      ..sort((a, b) => _sortOrder(a).compareTo(_sortOrder(b)));
    return rows;
  }

  List<ReconciliationResult> _applyFilters(List<ReconciliationResult> rows) {
    return rows.where((r) {
      if (_selectedStatuses.isNotEmpty &&
          !_selectedStatuses.contains(r.status)) {
        return false;
      }

      final pa = _platformAccountCtrl.text.trim();
      if (pa.isNotEmpty &&
          !(r.platformRecord?.account ?? '').contains(pa)) {
        return false;
      }

      final ba = _bankAccountCtrl.text.trim();
      if (ba.isNotEmpty &&
          !(r.bankRecord?.account ?? '').contains(ba)) {
        return false;
      }

      if (_platformAmountFilter.isNotEmpty) {
        final pAmt = r.platformRecord != null
            ? _formatAmount(r.platformRecord!.amount)
            : '';
        if (!pAmt.contains(_platformAmountFilter)) { return false; }
      }

      if (_bankAmountFilter.isNotEmpty) {
        final bAmt =
            r.bankRecord != null ? _formatAmount(r.bankRecord!.amount) : '';
        if (!bAmt.contains(_bankAmountFilter)) { return false; }
      }

      if (_platformDate != null) {
        final pd = r.platformRecord?.date;
        if (pd == null || !_sameDay(pd, _platformDate!)) { return false; }
      }

      if (_bankDate != null) {
        final bd = r.bankRecord?.date;
        if (bd == null || !_sameDay(bd, _bankDate!)) { return false; }
      }

      return true;
    }).toList();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _sortOrder(ReconciliationResult r) => switch (r.status) {
        ReconciliationStatus.differentDate => 0,
        ReconciliationStatus.differentAmount => 1,
        ReconciliationStatus.differentDateAndAmount => 2,
        ReconciliationStatus.unmatched when r.bankRecord != null => 3,
        ReconciliationStatus.unmatched => 4,
        ReconciliationStatus.fullMatch => 5,
      };

  Color? _statusColor(ReconciliationResult r) => switch (r.status) {
        ReconciliationStatus.differentDate => Colors.orange[800],
        ReconciliationStatus.differentAmount => Colors.blue[700],
        ReconciliationStatus.differentDateAndAmount => Colors.deepOrange[700],
        ReconciliationStatus.unmatched when r.bankRecord != null =>
          Colors.red[700],
        ReconciliationStatus.unmatched => Colors.purple[700],
        ReconciliationStatus.fullMatch => null,
      };

  String _statusLabel(ReconciliationResult r) => switch (r.status) {
        ReconciliationStatus.differentDate => 'تاريخ مختلف',
        ReconciliationStatus.differentAmount => 'مبلغ مختلف',
        ReconciliationStatus.differentDateAndAmount => 'تاريخ ومبلغ مختلفان',
        ReconciliationStatus.unmatched when r.bankRecord != null => 'بنك فقط',
        ReconciliationStatus.unmatched => 'منصة فقط',
        ReconciliationStatus.fullMatch => '',
      };

  String _formatAmount(double amount) {
    final rounded = (amount * 1000).round() / 1000;
    if (rounded == rounded.truncateToDouble()) return rounded.toInt().toString();
    final s = rounded.toStringAsFixed(3);
    final trimmed = s.replaceAll(RegExp(r'0+$'), '');
    return trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}/$m/$d';
  }

  @override
  Widget build(BuildContext context) {
    final allRows = _sort(widget.results);
    if (allRows.isEmpty) {
      return const Center(child: Text('لا توجد نتائج.'));
    }

    final filteredRows = _applyFilters(allRows);

    return LayoutBuilder(
      builder: (context, constraints) {
        final leftPad =
            constraints.maxWidth.isFinite && constraints.maxWidth > _totalWidth
                ? (constraints.maxWidth - _totalWidth) / 2
                : 0.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftPad),
            child: SizedBox(
              width: _totalWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterRow(),
                  _buildHeaderRow(),
                  const Divider(height: 1, thickness: 1),
                  Expanded(
                    child: filteredRows.isEmpty
                        ? const Center(
                            child: Text('لا توجد نتائج مطابقة للفلتر.'),
                          )
                        : ListView.builder(
                            itemCount: filteredRows.length,
                            itemBuilder: (ctx, i) =>
                                _buildDataRow(filteredRows[i], i),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: [
          _filterCell(
            _colAccount,
            _AccountFilter(
              controller: _platformAccountCtrl,
              onChanged: (_) => setState(() {}),
            ),
          ),
          _filterCell(
            _colAmount,
            _AmountFilter(
              controller: _platformAmountCtrl,
              onApply: (v) => setState(() => _platformAmountFilter = v),
            ),
          ),
          _filterCell(
            _colDate,
            _DateFilter(
              selectedDate: _platformDate,
              onDateSelected: (d) => setState(() => _platformDate = d),
            ),
          ),
          _filterCell(
            _colAccount,
            _AccountFilter(
              controller: _bankAccountCtrl,
              onChanged: (_) => setState(() {}),
            ),
          ),
          _filterCell(
            _colAmount,
            _AmountFilter(
              controller: _bankAmountCtrl,
              onApply: (v) => setState(() => _bankAmountFilter = v),
            ),
          ),
          _filterCell(
            _colDate,
            _DateFilter(
              selectedDate: _bankDate,
              onDateSelected: (d) => setState(() => _bankDate = d),
            ),
          ),
          _filterCell(
            _colStatus,
            _StatusFilter(
              selectedStatuses: _selectedStatuses,
              onChanged: (s) => setState(() => _selectedStatuses = s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: [
          _headerCell(_colAccount, 'رقم الحساب\n(المنصة)'),
          _headerCell(_colAmount, 'المبلغ\n(المنصة)'),
          _headerCell(_colDate, 'التاريخ\n(المنصة)'),
          _headerCell(_colAccount, 'رقم الحساب\n(البنك)'),
          _headerCell(_colAmount, 'المبلغ\n(البنك)'),
          _headerCell(_colDate, 'التاريخ\n(البنك)'),
          _headerCell(_colStatus, 'الحالة'),
        ],
      ),
    );
  }

  Widget _buildDataRow(ReconciliationResult result, int index) {
    final p = result.platformRecord;
    final b = result.bankRecord;
    final color = _statusColor(result);
    final bg = index.isEven ? Colors.white : Colors.grey.shade50;

    return ColoredBox(
      color: bg,
      child: Row(
        children: [
          _dataCell(_colAccount, p?.account ?? '', color),
          _dataCell(_colAmount, p != null ? _formatAmount(p.amount) : '', color),
          _dataCell(_colDate, p != null ? _formatDate(p.date) : '', color),
          _dataCell(_colAccount, b?.account ?? '', color),
          _dataCell(_colAmount, b != null ? _formatAmount(b.amount) : '', color),
          _dataCell(_colDate, b != null ? _formatDate(b.date) : '', color),
          _dataCell(_colStatus, _statusLabel(result), color),
        ],
      ),
    );
  }

  Widget _filterCell(double width, Widget child) => SizedBox(
        width: width,
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: child,
        ),
      );

  Widget _headerCell(double width, String label) => SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _dataCell(double width, String text, Color? color) => SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

// ─── Filter Widgets ────────────────────────────────────────────────────────────

class _AccountFilter extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _AccountFilter({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        hintText: 'بحث...',
        border: OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 11),
    );
  }
}

class _AmountFilter extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onApply;

  const _AmountFilter({required this.controller, required this.onApply});

  @override
  State<_AmountFilter> createState() => _AmountFilterState();
}

class _AmountFilterState extends State<_AmountFilter> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) widget.onApply(widget.controller.text.trim());
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      onSubmitted: (v) => widget.onApply(v.trim()),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        hintText: 'مبلغ...',
        border: OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 11),
      keyboardType: TextInputType.number,
    );
  }
}

class _DateFilter extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime?) onDateSelected;

  const _DateFilter({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDateSelected(picked);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 12),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                selectedDate != null ? _formatDate(selectedDate!) : 'تاريخ...',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selectedDate != null)
              GestureDetector(
                onTap: () => onDateSelected(null),
                child: const Icon(Icons.clear, size: 12),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}/$m/$d';
  }
}

class _StatusFilter extends StatelessWidget {
  final Set<ReconciliationStatus> selectedStatuses;
  final void Function(Set<ReconciliationStatus>) onChanged;

  const _StatusFilter({
    required this.selectedStatuses,
    required this.onChanged,
  });

  static final _options = <(ReconciliationStatus, String)>[
    (ReconciliationStatus.differentDate, 'تاريخ مختلف'),
    (ReconciliationStatus.differentAmount, 'مبلغ مختلف'),
    (ReconciliationStatus.differentDateAndAmount, 'تاريخ ومبلغ مختلفان'),
    (ReconciliationStatus.unmatched, 'غير متطابق'),
  ];

  @override
  Widget build(BuildContext context) {
    final label =
        selectedStatuses.isEmpty ? 'الكل' : '${selectedStatuses.length} محدد';

    return InkWell(
      onTap: () => _showDialog(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 11)),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    var current = Set<ReconciliationStatus>.from(selectedStatuses);
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('تصفية الحالة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _options.map((opt) {
              final (status, label) = opt;
              return CheckboxListTile(
                title: Text(label),
                value: current.contains(status),
                onChanged: (v) => setDialogState(() {
                  if (v == true) {
                    current.add(status);
                  } else {
                    current.remove(status);
                  }
                }),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onChanged({});
                Navigator.pop(ctx);
              },
              child: const Text('إلغاء الكل'),
            ),
            TextButton(
              onPressed: () {
                onChanged(current);
                Navigator.pop(ctx);
              },
              child: const Text('تطبيق'),
            ),
          ],
        ),
      ),
    );
  }
}
