// src/domain/repositories/settings_repository.dart
import 'package:gotpos/src/domain/entities/product.dart';

import '../../domain/entities/category.dart';

abstract class SettingsRepository {
  // Masa işlemleri
  Future<void> addTable(String name, int capacity);
  // Belki ileride: Future<void> updateTable(TableInfo table);
  // Belki ileride: Future<void> deleteTable(int tableId);

  // Ürün işlemleri
  Future<void> addProduct(String name, double price, String categoryId);
  // Belki ileride: Future<Product> getProduct(String productId);
  // Belki ileride: Future<List<Product>> getAllProducts();

  // Stok işlemleri
  Future<void> addStock(String productId, int quantity);
  // Belki ileride: Future<int> getStock(String productId);

  Future<List<Category>> getCategories();
  Future<List<Product>> getAllProducts();
  void addProductToBranch(String productId, double price);
}
