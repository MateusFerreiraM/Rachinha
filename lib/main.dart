import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://dgpkqhsmnboqmmydnzcj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRncGtxaHNtbmJvcW1teWRuemNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2ODIxODgsImV4cCI6MjA5NjI1ODE4OH0.4M_AlAixZusJoO0lcFqa5wj7Vc3BGOlkGQ1lKheqpy8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Racha Conta de Bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        iconTheme: const IconThemeData(
          color: AppColors.accent,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)
            .copyWith(secondary: AppColors.accent),
      ),
      home: const SplashScreen(),
    );
  }
}