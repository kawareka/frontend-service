// src/domain/entities/day_process_info.dart
class DayProcessInfo {
  final String openingTime; // Daha anlaşılır isimler kullanalım
  final String closingTime;
  final String description;
  final String status;

  DayProcessInfo({
    required this.openingTime,
    required this.closingTime,
    required this.description,
    required this.status,
  });

  // Fabrika metodu veya JSON dönüşümü için metotlar eklenebilir
  // factory DayProcessInfo.fromJson(Map<String, dynamic> json) { ... }
  // Map<String, dynamic> toJson() { ... }
}
