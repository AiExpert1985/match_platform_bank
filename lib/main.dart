import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match_platform_bank/features/transactions/presentation/screens/main_screen.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (FlutterErrorDetails details) {
        logError(details.exceptionAsString(), details.stack);
      };
      runApp(const ProviderScope(child: App()));
    },
    (error, stackTrace) {
      logError(error.toString(), stackTrace);
    },
  );
}

void logError(String error, StackTrace? stack) {
  try {
    File('crash_log.txt').writeAsStringSync(
      'Error: $error\nStack: $stack\n',
      mode: FileMode.append,
    );
  } catch (_) {}
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainScreen(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
  }
}
