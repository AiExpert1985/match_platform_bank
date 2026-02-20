import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match_platform_bank/features/transactions/domain/transaction_record.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_notifier.dart';
import 'package:match_platform_bank/features/transactions/presentation/providers/app_state.dart';
import 'package:match_platform_bank/features/transactions/presentation/widgets/import_button.dart';
import 'package:match_platform_bank/features/transactions/presentation/widgets/results_table.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bothImported = ref.watch(
      appProvider.select(
        (s) =>
            s.bankImport is ImportSuccess && s.platformImport is ImportSuccess,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Import zone
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  ImportButton(
                    source: TransactionSource.bank,
                    label: 'استيراد ملف البنك',
                  ),
                  ImportButton(
                    source: TransactionSource.platform,
                    label: 'استيراد ملف المنصة',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action zone
              ElevatedButton(
                onPressed: bothImported
                    ? () => ref.read(appProvider.notifier).reconcile()
                    : null,
                child: const Text('توليد'),
              ),
              const SizedBox(height: 16),
              // Result zone
              const Expanded(child: ResultsTable()),
              // Footer
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'نظام تدقيق الجباية الالكترونية للوارد اليومي - تنفيذ قسم الاتصالات و التحول الالكتوني في مركز توزيع كهرباء نينوى 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
