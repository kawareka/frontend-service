// src/data/repositories/in_memory_day_process_repository.dart
import '../../domain/entities/day_process_info.dart';
import '../../domain/repositories/day_process_repository.dart';

class InMemoryDayProcessRepository implements DayProcessRepository {
  final List<DayProcessInfo> _processes = [
    // Başlangıç mock verisi
    DayProcessInfo(
      openingTime: '19.04.2025 09:54:18',
      closingTime: '1.01.0001 00:00:00', // Henüz kapanmamış gibi
      description: 'İşlem 1 Açıklama',
      status: 'Açık',
    ),
  ];

  @override
  Future<List<DayProcessInfo>> getDayProcesses() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simülasyon
    return List.unmodifiable(_processes); // Listenin kopyasını döndür
  }

  @override
  Future<void> startDay() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Yeni bir gün işlemi ekle veya mevcut olanı güncelle
    print('[InMemoryDayProcessRepository] Gün başı yapıldı.');
    // _processes.add(...); // Gerçek implementasyon
  }

  @override
  Future<void> endDay() async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('[InMemoryDayProcessRepository] Gün sonu yapıldı.');
    // Mevcut açık işlemi kapat
  }

  @override
  Future<void> addCashToRegister(double amount) async {
    await Future.delayed(const Duration(milliseconds: 100));
    print(
      '[InMemoryDayProcessRepository] Kasaya \$${amount.toStringAsFixed(2)} eklendi. Toplam: \$_cashInRegister',
    );
  }
}
