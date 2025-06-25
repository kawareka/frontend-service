import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gotpos/src/domain/entities/product.dart';
import 'package:gotpos/src/domain/repositories/settings_repository.dart';

class ConnectProductDialogResult {
  final String name;
  ConnectProductDialogResult(this.name);
}

class ConnectProductDialog extends StatefulWidget {
  final SettingsRepository repository;

  const ConnectProductDialog({super.key, required this.repository});

  @override
  State<ConnectProductDialog> createState() => _ConnectProductDialog();
}

class _ConnectProductDialog extends State<ConnectProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  List<Product> _products = [];
  String? _selectedProductId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      // Repository'den kategorileri al
      final products = await widget.repository.getAllProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi verilebilir
      print('Kategoriler yüklenirken hata: $e');
    }
  }

  void _connectProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      widget.repository.addProductToBranch(
        _selectedProductId!,
        double.parse(_priceController.text.replaceAll(',', '.')),
      );
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi verilebilir
      print('Ürün eklenirken hata: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kategori seçimi
            DropdownButtonFormField<String>(
              value: _selectedProductId,
              decoration: const InputDecoration(
                labelText: 'Ürün',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Ürün seçin'),
              items:
                  _products.map((product) {
                    return DropdownMenuItem<String>(
                      value: product.id,
                      child: Row(
                        children: [
                          Icon(product.icon, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(product.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProductId = newValue;
                });
              },
              validator: (value) => value == null ? 'Ürün seçmelisiniz' : null,
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
              onFieldSubmitted: (_) => _isLoading ? null : _connectProduct(),
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
          onPressed: _isLoading ? null : _connectProduct,
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
