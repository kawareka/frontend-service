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
    primaryColor:
        Colors
            .indigo, // primaryColor yerine colorScheme.primary kullanılması önerilir
    appBarTheme: AppBarTheme(
      backgroundColor:
          Colors.indigo.shade900, // AppBar rengini tutarlı hale getirelim
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins', // Font ailesini belirtelim
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ), // AppBar ikon renkleri
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ), // Yatay padding ekleyelim
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins', // Font ailesini belirtelim
          fontWeight: FontWeight.bold, // Buton yazılarını kalın yapalım
        ),
      ),
    ),
    // Diğer tema ayarları...
    tabBarTheme: TabBarTheme(
      // POSScreen için TabBar temasını da buraya ekleyebiliriz
      labelColor: Colors.white,
      unselectedLabelColor: Colors.indigo.shade100,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontSize:
            24.0, // Tutarlılık için AppBar başlığı ile aynı veya yakın boyut
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize:
            22.0, // Tutarlılık için AppBar başlığı ile aynı veya yakın boyut
        fontFamily: 'Poppins',
      ),
      dividerColor:
          Colors.transparent, // AppBar'daki divider ile çakışmaması için
    ),
    // Input dialogları için tema
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.indigo.shade700, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.grey.shade800,
        fontFamily: 'Poppins',
      ),
    ),
  );

  // İsteğe bağlı olarak karanlık tema
  // static final ThemeData darkTheme = ThemeData(...);
}
