import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_notifier.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_state.dart';

class ImportButton extends ConsumerWidget {
  final TransactionSource source;
  final String label;

  const ImportButton({
    super.key,
    required this.source,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(
      appProvider.select(
        (s) => source == TransactionSource.bank ? s.bankImport : s.platformImport,
      ),
    );

    final isLoading = importState is ImportLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () => ref.read(appProvider.notifier).importFile(source),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
        const SizedBox(height: 4),
        _StatusIndicator(importState: importState),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final ImportState importState;

  const _StatusIndicator({required this.importState});

  @override
  Widget build(BuildContext context) {
    return switch (importState) {
      ImportSuccess() => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'تم الاستيراد',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
      ImportFailure() => const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text(
              'فشل الاستيراد',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
      _ => const SizedBox(height: 20),
    };
  }
}
