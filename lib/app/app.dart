import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/app/app_shell.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/core/theme/app_theme.dart';

/// Root application widget.
class VitalPulseApp extends ConsumerWidget {
  const VitalPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppShell(),
      );
}
