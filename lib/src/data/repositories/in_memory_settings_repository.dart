// src/data/repositories/in_memory_settings_repository.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gotpos/src/core/utils/app_constants.dart';
import 'package:gotpos/src/domain/entities/product.dart';
import 'package:http/http.dart' as http;
import 'package:gotpos/src/domain/entities/category.dart';

import 'dart:convert';
import '../../domain/repositories/settings_repository.dart';

class InMemorySettingsRepository implements SettingsRepository {
  // Verileri saklamak için listeler (Mock data)
  final List<Map<String, dynamic>> _tables = [];
  final List<Map<String, dynamic>> _products = [];
  final Map<String, int> _stock = {};
  int _lastTableId = 0; // Otomatik ID için
  int _lastProductId = 0; // Otomatik ID için

  @override
  Future<void> addTable(String name, int capacity) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simülasyon
    _lastTableId++;
    _tables.add({
      'id': _lastTableId,
      'name': name,
      'capacity': capacity,
      'status': 'empty',
    });
    print(
      '[InMemorySettingsRepository] Masa eklendi: ID: $_lastTableId, Ad: $name, Kapasite: $capacity',
    );
  }

  @override
  Future<void> addProduct(String name, double price, String categoryId) async {
    final response = await http.post(
      Uri.parse(AppConstants.addProductUrl),
      headers: {
        'accept': 'application/json',
        'X-API-Key': AppConstants.menuApiKey,
      },
      body: json.encode({
        'product_name': name,
        'base_price': price,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonBody = json.decode(response.body);
      final String productId = jsonBody['data']['id'];

      addProductToBranch(productId, price);
    } else {
      throw Exception('Failed to add product');
    }
  }

  @override
  Future<void> addStock(String productId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simülasyon
    _stock[productId] = (_stock[productId] ?? 0) + quantity;
    print(
      '[InMemorySettingsRepository] Stok güncellendi: Ürün ID: $productId, Yeni Miktar: ${_stock[productId]}',
    );
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse(AppConstants.categoryUrl),
      headers: {
        'accept': 'application/json',
        'X-API-Key': 'menu-service-staging-key-2024',
      },
    );

    if (response.statusCode == 200) {
      print("categories fetched successfully");

      final jsonBody = json.decode(response.body);
      final List<dynamic> categoryJson = jsonBody['data']['categories'];

      return categoryJson.map((category) {
        return Category(
          id: category['id'],
          name: category['category_name'],
          icon: _mapCategoryToIcon(category['category_name']),
        ); // Varsayılan ikon
      }).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(
      Uri.parse(AppConstants.getAllProductsUrl),
      headers: {
        'accept': 'application/json',
        'X-API-Key': AppConstants.menuApiKey,
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final List<dynamic> productJson = jsonBody['data']['products'];
      ;

      List<Product> products =
          productJson.map((product) {
            final dynamic productCategoryJson = product['category'];
            print("productCategoryJson: $productCategoryJson");
            return Product(
              id: product['id'],
              name:
                  product['product_name'] +
                  ' | (' +
                  productCategoryJson['category_name'] +
                  ')',
              price: json.decode(product['base_price']).toDouble(),
              categoryId: product['category_id'],
              icon: Icons.shopping_bag, // Varsayılan ikon
            );
          }).toList();
      products.sort((a, b) => b.name.compareTo(a.categoryId));
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void addProductToBranch(String productId, double price) async {
    final response = await http.post(
      Uri.parse(AppConstants.addProductToBranchUrl),
      headers: {
        'accept': 'application/json',
        'X-API-Key': AppConstants.menuApiKey,
      },
      body: json.encode({
        'discount': 0,
        'first_price': price,
        'product_id': productId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Ürün şubeye eklendi.');
    } else {
      throw Exception('Failed to add product');
    }
  }

  IconData _mapCategoryToIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'coffee':
      case 'drink':
      case 'beverage':
      case 'kahveler':
        return Icons.local_cafe;
      case 'food':
      case 'food':
      case 'food':
        return Icons.restaurant;
      case 'dessert':
      case 'tatlılar':
      case 'Tatlılar':
        return Icons.cake;
      case 'sandviçler':
      case 'fast food':
      case 'fast food':
        return Icons.fastfood;
      default:
        return Icons.category;
    }
  }
}
