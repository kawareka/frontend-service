// src/presentation/pages/pos/widgets/product_grid.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/repositories/pos_repository.dart';
import 'product_card.dart'; // ProductCard widget'ını import et

class ProductGrid extends StatefulWidget {
  final String categoryId;
  final PosRepository posRepository;
  final ValueChanged<Product>
  onProductTap; // Ürüne tıklandığında çağrılacak fonksiyon

  const ProductGrid({
    super.key,
    required this.categoryId,
    required this.posRepository,
    required this.onProductTap,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(covariant ProductGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kategori değiştiyse ürünleri yeniden yükle
    if (oldWidget.categoryId != widget.categoryId) {
      _loadProducts();
    }
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = widget.posRepository.getProductsByCategory(
        widget.categoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Kategoriler arası geçişte hızlı yükleme için önceki veriyi gösterebiliriz (opsiyonel)
          // if (snapshot.hasData) return _buildGrid(snapshot.data!);
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ürünler yüklenemedi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Bu kategoride ürün bulunamadı.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return _buildGrid(snapshot.data!);
      },
    );
  }

  Widget _buildGrid(List<Product> products) {
    final crossAxisCount = _calculateGridColumns(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0, // Kartların en/boy oranı
        crossAxisSpacing: 12, // Aralıkları biraz azaltalım
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        // ProductCard widget'ını kullanıyoruz
        return ProductCard(
          product: product,
          onTap:
              () => widget.onProductTap(
                product,
              ), // Tıklama olayını yukarı iletiyoruz
        );
      },
    );
  }

  // Grid sütun sayısını hesaplama (POSPage'den kopyalandı, ortak bir yere taşınabilir)
  int _calculateGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Layout'a göre sütun sayısı ayarlaması (daha detaylı yapılabilir)
    if (width > 1600) return 5;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 500) return 2;
    return 2; // En küçük ekranlar
  }
}
