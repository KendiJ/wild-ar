import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/ar_experience/presentation/screens/ar_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: WildArApp(),
    ),
  );
}

/// Root widget of the Wild AR application configured with Material 3 and modern dark AR aesthetics.
class WildArApp extends StatelessWidget {
  const WildArApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F17),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          brightness: Brightness.dark,
          primary: const Color(0xFF00BFA5),
          secondary: Colors.amberAccent,
          surface: const Color(0xFF161624),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161624),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const ArDashboardScreen(),
    );
  }
}
