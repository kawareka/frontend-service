import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    fontFamily: 'Poppins',
    primaryColor: Colors.indigo,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.indigo.shade900,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    cardTheme: const CardThemeData(  // CardTheme -> CardThemeData
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(  // TabBarTheme -> TabBarThemeData
      labelColor: Colors.white,
      unselectedLabelColor: Color(0xFFE8EAF6),
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 22.0,
        fontFamily: 'Poppins',
      ),
      dividerColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF616161)),
    ),
    dialogTheme: const DialogThemeData(  // DialogTheme -> DialogThemeData
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Color(0xFF424242),
        fontFamily: 'Poppins',
      ),
    ),
  );
}