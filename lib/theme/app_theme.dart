import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color darkNavy = Color(0xFF071529);
  static const Color navySurface = Color(0xFF0F1E3C);
  static const Color navyBackground = Color(0xFF0A1128);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color deepSky = Color(0xFF0284C7);
  static const Color primaryBlue = Color(0xFF2563EB);

  // Service Accent Colors
  static const Color foodGreen = Color(0xFF16A34A);
  static const Color foodGreenLight = Color(0xFF22C55E);
  static const Color foodYellow = Color(0xFFFACC15);

  static const Color rideBlue = Color(0xFF0284C7);
  static const Color rideBlueDark = Color(0xFF1D4ED8);

  static const Color savingsOrange = Color(0xFFEA580C);
  static const Color savingsOrangeLight = Color(0xFFFB923C);
  static const Color savingsGold = Color(0xFFFBBF24);

  // Neutrals
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  static const Color pageBg = Color(0xFFE8EEF5);
  static const Color mobilePhoneBg = Color(0xFFF4F7FB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: mobilePhoneBg,
        onSurface: slate900,
      ),
      scaffoldBackgroundColor: mobilePhoneBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
