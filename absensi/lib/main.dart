import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/lock_screen.dart';
import 'config/app_config.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  final bool isLoggedIn = await ApiService.isLoggedIn();
  final bool isBioEnabled = await ApiService.isBiometricEnabled();

  runApp(MyApp(isLoggedIn: isLoggedIn, isBioEnabled: isBioEnabled));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isBioEnabled;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.isBioEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasaun Presensa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConfig.primaryColorHex),
          primary: const Color(AppConfig.primaryColorHex),
          secondary: const Color(AppConfig.secondaryColorHex),
          surface: Colors.white,
          brightness: Brightness.light,
        ).copyWith(secondary: const Color(AppConfig.secondaryColorHex)),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(AppConfig.primaryColorHex),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: isLoggedIn
          ? (isBioEnabled ? const LockScreen() : const MainScreen())
          : const LoginScreen(),
    );
  }
}
