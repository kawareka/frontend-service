// src/presentation/pages/pos/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  // Kategori rengini almak için yardımcı metod (Repository'ye erişim gerektirir)
  // Bu ideal değil, Kategori bilgisi Product içinde olmalı veya Grid'den gelmeli.
  // Şimdilik varsayılan renk kullanacağız veya basit bir harita oluşturacağız.
  Color _getCategoryColor(BuildContext context) {
    // Basit harita (daha iyisi repository'den almak)
    final colors = {
      'beverage': Colors.blue.shade700,
      'food': Colors.orange.shade700,
      'dessert': Colors.pink.shade400,
      'fast_food': Colors.red.shade600,
    };
    return colors[product.categoryId] ?? Colors.pink; // Eşleşmezse gri
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(context); // Kategori rengini al

    return Card(
      elevation: 2,
      shadowColor: categoryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: categoryColor.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: categoryColor.withOpacity(0.1),
        highlightColor: categoryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // İçeriği dikeyde ortala
            crossAxisAlignment:
                CrossAxisAlignment.center, // İçeriği yatayda ortala
            children: [
              Icon(product.icon, size: 40, color: categoryColor), // İkon boyutu
              const SizedBox(height: 12),
              Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  // Daha uygun stil
                  fontWeight: FontWeight.w600,
                  // fontSize: 16, // Font boyutu
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Uzun isimler için
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(), // Fiyatı dibe itmek için
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${product.price.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Fiyat font boyutu
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
