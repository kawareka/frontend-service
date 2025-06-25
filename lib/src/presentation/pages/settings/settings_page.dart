// src/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:gotpos/src/presentation/pages/settings/widgets/connect_product_dialog.dart';
import '../../../domain/repositories/settings_repository.dart';
// Dialog widget'larını import et
import 'widgets/add_table_dialog.dart';
import 'widgets/add_product_dialog.dart';
import 'widgets/add_stock_dialog.dart';

// Ana sayfa widget'ı (önceki 'Setting' sınıfı)
class SettingsPage extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const SettingsPage({
    super.key,
    required this.settingsRepository, // Repository dışarıdan alınacak
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Temayı al

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.of(
                context,
              ).pushReplacementNamed('/'), // Ana sayfaya git, // Geri dön
        ),
        // Home butonu eklenebilir (isteğe bağlı)
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed:
                () => Navigator.of(
                  context,
                ).pushReplacementNamed('/'), // Ana sayfaya git
          ),
        ],

        title: const Text('Yönetim Paneli'),
        // backgroundColor: Colors.indigo.shade900, // Tema'dan gelecek
      ),
      // Drawer eklemeye gerek yok, bu sayfa genelde Drawer'dan açılır.
      // drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: _calculateCrossAxisCount(
            context,
          ), // Dinamik sütun sayısı
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5, // Oranı ayarlayalım
          children: [
            _ActionCard(
              icon: Icons.table_bar_outlined, // Outline ikonlar
              label: 'Masa Ekle',
              color: theme.colorScheme.primary, // Ana renk
              onTap: () => _showAddTableDialog(context),
            ),
            _ActionCard(
              icon: Icons.add_box_outlined, // Outline ikonlar
              label: 'Ürün Oluştur',
              color: theme.colorScheme.secondary, // İkincil renk
              onTap: () => _showAddProductDialog(context),
            ),
            _ActionCard(
              icon: Icons.join_full, // Outline ikonlar
              label: 'Ürün Bağla',
              color: theme.colorScheme.secondary, // İkincil renk
              onTap: () => _showConnectProductDialog(context),
            ),
            _ActionCard(
              icon: Icons.inventory_2_outlined, // Outline ikonlar
              label: 'Stok Gir',
              color: theme.colorScheme.tertiary, // Üçüncül renk (varsa)
              onTap: () => _showAddStockDialog(context),
            ),
            // Gelecekte eklenebilecek diğer yönetim kartları...
            _ActionCard(
              icon: Icons.category_outlined,
              label: 'Kategori Yönet',
              color: Colors.teal, // Örnek renk
              onTap: () => print('Kategori Yönet Tıklandı'),
            ),
          ],
        ),
      ),
    );
  }

  // Ekran boyutuna göre sütun sayısını hesapla
  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2; // Daha küçük ekranlar için
  }

  // Dialog gösterme fonksiyonları (Repository'yi dialog'a gönderiyoruz)

  Future<void> _showAddTableDialog(BuildContext context) async {
    final result = await showDialog<TableDialogResult>(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
      builder: (_) => AddTableDialog(repository: settingsRepository),
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masa "${result.name}" başarıyla eklendi.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    // TODO: Ürün eklerken kategori seçimi de eklenmeli. Şimdilik varsayılan ID kullanıyoruz.
    final result = await showDialog<ProductDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddProductDialog(repository: settingsRepository),
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ürün "${result.name}" başarıyla eklendi.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showConnectProductDialog(BuildContext context) async {
    // TODO: Ürün eklerken kategori seçimi de eklenmeli. Şimdilik varsayılan ID kullanıyoruz.
    final result = await showDialog<ConnectProductDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConnectProductDialog(repository: settingsRepository),
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ürün "${result.name}" başarıyla eklendi.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showAddStockDialog(BuildContext context) async {
    // TODO: Stok girerken mevcut ürünlerin listesi repository'den alınmalı.
    final result = await showDialog<StockDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddStockDialog(repository: settingsRepository),
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok güncellendi: ${result.productId} -> ${result.quantity} adet.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// --- Helper Widget: _ActionCard ---
// Bu widget sayfaya özel olduğu için burada kalabilir veya ortak hale getirilebilir.

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Hafif artırılmış elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Ortala
            children: [
              // İkonu daha belirgin yapalım
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle, // Yuvarlak arka plan
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  // Stil tema'dan
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2, // Uzun etiketler için
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
