// src/presentation/pages/settings/widgets/add_table_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatter için
import '../../../../domain/repositories/settings_repository.dart';

// Dialog sonucunu taşımak için sınıf
class TableDialogResult {
  final String name;
  final int capacity;
  TableDialogResult(this.name, this.capacity);
}

class AddTableDialog extends StatefulWidget {
  final SettingsRepository repository;

  const AddTableDialog({super.key, required this.repository});

  @override
  State<AddTableDialog> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<AddTableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController(
    text: '1',
  ); // Başlangıç değeri
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveTable() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Kaydetme işlemi form içinde değil burada

      final name = _nameController.text.trim();
      final capacity =
          int.tryParse(_capacityController.text) ?? 1; // Hata kontrolü

      setState(() => _isLoading = true);
      try {
        // Repository üzerinden ekleme işlemi
        await widget.repository.addTable(name, capacity);
        // Başarılı olursa sonucu döndürerek dialog'u kapat
        Navigator.pop(context, TableDialogResult(name, capacity));
      } catch (e) {
        // Hata durumunda kullanıcıya bilgi ver
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Masa eklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // finally { // Her durumda loading state'i kapat
      //   if (mounted) { // Widget hala ağaçta ise
      //     setState(() => _isLoading = false);
      //   }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // shape: ..., // Tema'dan gelecek
      title: const Text('Masa Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Masa Adı'),
              textInputAction: TextInputAction.next, // Sonraki alana geçiş
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Masa adı boş bırakılamaz'
                          : null,
            ),
            const SizedBox(height: 16), // Alanlar arası boşluk
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Kapasite'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ], // Sadece rakam girişi
              textInputAction: TextInputAction.done, // Kaydetmeye hazır
              validator: (value) {
                final n = int.tryParse(value ?? '');
                return n == null || n < 1
                    ? 'Geçerli bir kapasite girin (min 1)'
                    : null;
              },
              onFieldSubmitted:
                  (_) => _isLoading ? null : _saveTable(), // Enter ile kaydet
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context), // Kapat
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTable, // Kaydet
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
