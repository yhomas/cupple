import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/router/app_router.dart';
import 'core/debug/debug_overlay.dart';

class CuppleApp extends ConsumerWidget {
  final String? firebaseError;

  const CuppleApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Cupple',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        Widget content = child ?? const SizedBox.shrink();
        if (firebaseError != null) {
          content = Column(
            children: [
              Material(
                color: Colors.red.shade700,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      firebaseError!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
              Expanded(child: content),
            ],
          );
        }
        return DebugOverlay(child: content);
      },
    );
  }
}
