// src/domain/repositories/pos_repository.dart
import '../entities/category.dart';
import '../entities/product.dart';

abstract class PosRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProductsByCategory(String categoryId);
  // Future<void> processPayment(List<OrderItem> items, String paymentMethod); // Ödeme işlemi domain'e taşınabilir
  // Future<Receipt> printReceipt(List<OrderItem> items, double total); // Makbuz domain'e taşınabilir
}
