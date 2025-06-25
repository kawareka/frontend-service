import 'package:flutter/material.dart';
import 'package:gotpos/src/data/repositories/in_memory_day_process_repository.dart';
import 'package:gotpos/src/data/repositories/in_memory_settings_repository.dart';
import 'core/theme/app_theme.dart'; // Tema dosyasını import edeceğiz
import 'presentation/pages/day_process/day_process_page.dart'; // Başlangıç sayfasını import ediyoruz
// import 'core/navigation/app_routes.dart'; // Eğer isimlendirilmiş rotalar kullanacaksak

class GotPosApp extends StatelessWidget {
  const GotPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GotPOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Merkezi tema
      // themeMode: ThemeMode.light, // Gerekirse tema modu
      // darkTheme: AppTheme.darkTheme, // Karanlık tema (isteğe bağlı)

      // Başlangıç ekranı (veya isimlendirilmiş rotalar)
      home: DayProcessPage(
        dayProcessRepository: InMemoryDayProcessRepository(),
        settingsRepository: InMemorySettingsRepository(),
      ), // Artık MaterialApp içermeyen sayfa widget'ı
      // Eğer isimlendirilmiş rotalar kullanılıyorsa:
      // initialRoute: AppRoutes.dayProcess,
      // onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
