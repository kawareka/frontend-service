// src/presentation/pages/settings/widgets/add_stock_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/repositories/settings_repository.dart';
// import '../../../../domain/entities/product.dart'; // Ürünleri almak için

class StockDialogResult {
  final String productId;
  final int quantity;
  StockDialogResult(this.productId, this.quantity);
}

class AddStockDialog extends StatefulWidget {
  final SettingsRepository repository;
  // TODO: Ürün listesi buraya gelmeli (ID ve isimleri)
  // final List<Product> products;

  const AddStockDialog({super.key, required this.repository});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId; // Seçilen ürün ID'si
  final _quantityController = TextEditingController(text: '1');
  bool _isLoading = false;

  // TODO: Ürün listesini initState içinde veya FutureBuilder ile yükle
  final List<DropdownMenuItem<String>> _productItems = [
    // Bu kısım dinamik olarak doldurulmalı
    const DropdownMenuItem(value: 'prod_1', child: Text('Su')),
    const DropdownMenuItem(value: 'prod_2', child: Text('Cola')),
    const DropdownMenuItem(value: 'prod_7', child: Text('Pizza')),
    // ... diğer ürünler
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveStock() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Kaydetme

      final quantity = int.tryParse(_quantityController.text) ?? 0;

      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bir ürün seçin'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Miktar 0\'dan büyük olmalı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        await widget.repository.addStock(_selectedProductId!, quantity);
        Navigator.pop(
          context,
          StockDialogResult(_selectedProductId!, quantity),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok eklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stok Girişi'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: _productItems, // Dinamik liste kullanılacak
              value: _selectedProductId,
              hint: const Text('Ürün Seçin'), // Başlangıçta görünen yazı
              decoration: const InputDecoration(labelText: 'Ürün'),
              validator:
                  (value) => value == null ? 'Lütfen bir ürün seçin' : null,
              onChanged: (value) {
                setState(() => _selectedProductId = value);
              },
              isExpanded: true, // Genişliği doldur
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Miktar (Adet)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              validator: (value) {
                final n = int.tryParse(value ?? '');
                return n == null || n <= 0
                    ? 'Geçerli bir miktar girin (> 0)'
                    : null;
              },
              onFieldSubmitted: (_) => _isLoading ? null : _saveStock(),
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
          onPressed: _isLoading ? null : _saveStock,
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
