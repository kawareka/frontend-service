// src/domain/entities/product.dart
import 'package:flutter/material.dart'; // IconData için gerekli

class Product {
  final String id; // Ürünü unique olarak tanımlamak için ID ekleyelim
  final String name;
  final double price;
  String categoryId;
  final IconData icon;
  int quantity = 1;

  Product({
    required this.id, // ID ekledik
    required this.name,
    required this.price,
    this.categoryId = '',
    this.icon = Icons.fastfood, // Varsayılan ikon
    this.quantity = 1,
  });
}
