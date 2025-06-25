// src/domain/entities/order_item.dart
class OrderItem {
  final String productId; // Product ID'sini tutalım
  final String name;
  final int quantity;
  final double price; // Ürünün o anki fiyatı
  // final String categoryId; // Kategori ID'si yerine Product'tan alınabilir, gerekirse eklenebilir

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    // required this.categoryId,
  });

  double get total => quantity * price;
}
