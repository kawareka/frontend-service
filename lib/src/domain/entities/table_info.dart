// src/domain/entities/table_info.dart
enum TableStatus { empty, occupied } // Daha İngilizce ve standart isimler

class TableInfo {
  final String id;
  final String name;
  final TableStatus status;
  final int
  capacity; // Kapasite bilgisini de ekleyelim (setting_page'den geliyordu)

  TableInfo({
    required this.id,
    required this.name,
    this.status = TableStatus.empty,
    required this.capacity, // Zorunlu hale getirelim
  });

  // Gelecekte gerekirse ek metotlar
  // bool get isEmpty => status == TableStatus.empty;
}
