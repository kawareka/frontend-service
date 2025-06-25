import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/app.dart'; // Yeni oluşturulacak app.dart dosyasını import ediyoruz

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Servislerin veya Repository'lerin başlatılması (eğer gerekliyse)
  // Örneğin, basit bir Service Locator veya Dependency Injection burada kurulabilir.
  // _setupServices();

  runApp(const GotPosApp()); // MaterialApp'ı içeren ana widget'ı çalıştırıyoruz
}

 // // Örnek servis başlatma fonksiyonu (DI/SL için)
 // void _setupServices() {
 //   // GetIt.I.registerSingleton<TableService>(InMemoryTableService());
 //   // GetIt.I.registerSingleton<ProductService>(InMemoryProductService());
 //   // GetIt.I.registerSingleton<StockService>(InMemoryStockService());
 //   // ... diğer servisler
 // }