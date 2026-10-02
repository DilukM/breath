import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'data/storage/local_storage.dart';
import 'presentation/providers/breathing_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup dependencies
  await setupDependencies();

  final hasSeenOnboarding = getIt<LocalStorage>().hasSeenOnboarding();

  runApp(BreathApp(
    initialRoute: hasSeenOnboarding ? AppRoutes.home : AppRoutes.onboarding,
  ));
}

class BreathApp extends StatelessWidget {
  final String initialRoute;

  const BreathApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<BreathingProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ThemeProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: initialRoute,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
