// src/presentation/pages/settings/widgets/add_product_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/product.dart';

class ProductDialogResult {
  final String name;
  final double price;
  // final String categoryId; // Gerekirse kategori de döndürülebilir
  ProductDialogResult(this.name, this.price);
}

class AddProductDialog extends StatefulWidget {
  final SettingsRepository repository;
  // TODO: Kategori listesi buraya gelmeli
  // final List<Category> categories;

  const AddProductDialog({super.key, required this.repository});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Repository'den kategorileri al
      final categories = await widget.repository.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi verilebilir
      print('Kategoriler yüklenirken hata: $e');
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Geçici ID
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        categoryId: _selectedCategoryId!,
        icon: Icons.shopping_bag, // Varsayılan ikon
      );

      // Ürünü kaydet (repository'de saveProduct metodu gerekli)
      // await widget.repository.saveProduct(product);
      await widget.repository.addProduct(
        product.name,
        product.price,
        product.categoryId,
      );
      Navigator.pop(context); // Dialog'u kapat
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ürün kaydedilirken hata: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /*
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final name = _nameController.text.trim();
      final price =
          double.tryParse(_priceController.text.replaceAll(',', '.')) ??
          0.0; // Virgül/nokta kontrolü
      // final categoryId = _selectedCategoryId ?? 'default_category'; // Seçilen veya varsayılan kategori

      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fiyat 0\'dan büyük olmalı'),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Fiyat geçersizse işlemi durdur
      }

      // if (_selectedCategoryId == null) { // Kategori kontrolü
      //    ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Lütfen bir kategori seçin'), backgroundColor: Colors.orange),
      //    );
      //    return;
      // }

      setState(() => _isLoading = true);
      try {
        // TODO: Repository metodunu categoryId ile güncelle
        await widget.repository.addProduct(name, price, 'default_category_id');
        Navigator.pop(context, ProductDialogResult(name, price));
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ürün eklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ürün Adı'),
              textInputAction: TextInputAction.next,
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Ürün adı boş bırakılamaz'
                          : null,
            ),
            const SizedBox(height: 16),

            // Kategori seçimi
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Kategori seçin'),
              items:
                  _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color, size: 20),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategoryId = newValue;
                });
              },
              validator:
                  (value) => value == null ? 'Kategori seçmelisiniz' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Fiyat (₺)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*[,.]?\d{0,2}'),
                ), // Para formatı
              ],
              textInputAction: TextInputAction.done,
              validator: (value) {
                final d = double.tryParse((value ?? '').replaceAll(',', '.'));
                return d == null || d <= 0
                    ? 'Geçerli bir fiyat girin (> 0)'
                    : null;
              },
              onFieldSubmitted: (_) => _isLoading ? null : _saveProduct(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Kaydet'),
        ),
      ],
    );
  }
}
