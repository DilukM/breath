import 'package:get_it/get_it.dart';
import '../../data/storage/local_storage.dart';
import '../../presentation/providers/breathing_provider.dart';
import '../../presentation/providers/theme_provider.dart';

/// Dependency injection setup using get_it
final GetIt getIt = GetIt.instance;

/// Setup all dependencies
Future<void> setupDependencies() async {
  // Register LocalStorage as singleton
  final localStorage = LocalStorage();
  await localStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);

  // Register ThemeProvider as singleton
  getIt.registerSingleton<ThemeProvider>(
    ThemeProvider(getIt<LocalStorage>()),
  );

  // Register BreathingProvider as factory (new instance each time)
  getIt.registerFactory<BreathingProvider>(
    () => BreathingProvider(localStorage: getIt<LocalStorage>()),
  );
}

/// Clean up dependencies
Future<void> cleanupDependencies() async {
  await getIt<LocalStorage>().close();
  await getIt.reset();
}
