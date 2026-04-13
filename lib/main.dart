import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/main_navigation/presentation/screens/splash_screen.dart';
import 'core/services/data_service.dart';
import 'core/constants/app_strings.dart';

/// Entry point of the application.
/// Initializes app services and runs the root widget.
void main() async {
  // Required for accessing platform services like SharedPreferences during startup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistence and data management
  await dataService.init();

  runApp(const AntigravityFirstSyncApp());
}

/// Global notifier for managing the application's theme mode (Light/Dark).
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// Root widget of the AI Discount Calculator application.
class AntigravityFirstSyncApp extends StatelessWidget {
  const AntigravityFirstSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          // Fetch application title from centralized string file
          title: AppStrings.appName,

          // Use centralized theme definitions
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,

          // Set splash screen as the root screen
          home: const SplashScreen(),

          // Remove debug banner for a cleaner premium look
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
