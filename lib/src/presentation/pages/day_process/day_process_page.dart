import 'package:flutter/material.dart';
import 'package:gotpos/src/domain/repositories/settings_repository.dart';
import 'package:gotpos/src/presentation/pages/settings/settings_page.dart';
import '../../../domain/entities/day_process_info.dart';
import '../../../domain/repositories/day_process_repository.dart';
import '../../widgets/action_button.dart'; // Yeni ActionButton widget'ı
import '../../widgets/app_drawer.dart'; // Ortak drawer

class DayProcessPage extends StatefulWidget {
  // Repository'yi dışarıdan alacak şekilde güncelleyelim (DI için hazırlık)
  final DayProcessRepository dayProcessRepository;
  final SettingsRepository settingsRepository;

  const DayProcessPage({
    super.key,
    // Geçici olarak burada instance oluşturuyoruz, idealde DI ile sağlanmalı
    required this.dayProcessRepository,
    required this.settingsRepository,
  });

  @override
  State<DayProcessPage> createState() => _DayProcessPageState();
}

class _DayProcessPageState extends State<DayProcessPage> {
  late Future<List<DayProcessInfo>> _dayProcessesFuture;

  @override
  void initState() {
    super.initState();
    _loadDayProcesses();
  }

  void _loadDayProcesses() {
    setState(() {
      _dayProcessesFuture = widget.dayProcessRepository.getDayProcesses();
    });
  }

  Future<void> _startDay() async {
    // Kullanıcıya geri bildirim ver (örneğin loading indicator)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gün başı işlemi başlatılıyor...')),
    );
    try {
      await widget.dayProcessRepository.startDay();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gün başı başarıyla yapıldı.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDayProcesses(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _endDay() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gün sonu işlemi başlatılıyor...')),
    );
    try {
      await widget.dayProcessRepository.endDay();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gün sonu başarıyla yapıldı.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDayProcesses(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addCash() async {
    // Basit bir dialog ile miktar alalım
    final amount = await _showAddCashDialog();
    if (amount != null && amount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${amount.toStringAsFixed(2)} ₺ kasaya ekleniyor...'),
        ),
      );
      try {
        await widget.dayProcessRepository.addCashToRegister(amount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kasaya para eklendi.'),
            backgroundColor: Colors.green,
          ),
        );
        // Burada listeyi yenilemeye gerek yok ama gerekirse _loadDayProcesses();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Basit para ekleme dialog'u
  Future<double?> _showAddCashDialog() {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Kasaya Para Ekle'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Miktar (₺)',
                prefixText: '₺ ',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(controller.text);
                  Navigator.pop(context, amount);
                },
                child: const Text('Ekle'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp widget'ını kaldırdık, doğrudan Scaffold dönüyoruz.
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.indigo.shade900, // Tema'dan gelecek
        title: const Text('GotPOS'), // Stil Tema'dan gelecek
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDayProcesses, // Yenileme işlemi
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Ayarlar sayfasına gitmek için AppDrawer'daki yöntemi kullanabiliriz
              // Veya Navigator.push(...) ile doğrudan gidebiliriz
              // Şimdilik Drawer'daki Ayarlar'ı kullanmak daha merkezi.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SettingsPage(
                        settingsRepository: widget.settingsRepository,
                      ),
                ),
              );
            },
            tooltip: 'Ayarlar',
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawer(), // Ortak Drawer'ı kullanıyoruz
      body: Row(
        children: [
          // Sol taraf (tablo)
          Expanded(
            flex: 4,
            child: _buildTableSection(), // Ayrı bir metoda taşıdık
          ),
          // Sağ taraf (işlem butonları)
          Expanded(
            flex: 1,
            child: _buildActionButtonsPanel(), // Ayrı bir metoda taşıdık
          ),
        ],
      ),
    );
  }

  // Tablo bölümünü oluşturan widget
  Widget _buildTableSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  Theme.of(
                    context,
                  ).appBarTheme.backgroundColor, // Tema ile uyumlu
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'GÜN İŞLEMLERİ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tablo başlıkları
          _buildTableHeader(),
          // Tablo verileri (FutureBuilder ile)
          Expanded(
            child: FutureBuilder<List<DayProcessInfo>>(
              future: _dayProcessesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Gün işlemi bulunamadı.'));
                }

                final processes = snapshot.data!;
                return ListView.builder(
                  itemCount: processes.length,
                  itemBuilder: (context, index) {
                    final process = processes[index];
                    return _buildTableRow(process);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tablo başlığını oluşturan widget
  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor, // Tema ile uyumlu
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 1, child: _TableHeaderCell('AÇILIŞ')),
          Expanded(flex: 1, child: _TableHeaderCell('KAPANIŞ')),
          Expanded(flex: 1, child: _TableHeaderCell('AÇIKLAMA')),
          Expanded(flex: 1, child: _TableHeaderCell('DURUM')),
        ],
      ),
    );
  }

  // Tek bir tablo satırını oluşturan widget
  Widget _buildTableRow(DayProcessInfo process) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _TableCell(process.openingTime)),
          Expanded(flex: 1, child: _TableCell(process.closingTime)),
          Expanded(flex: 1, child: _TableCell(process.description)),
          Expanded(flex: 1, child: _TableCell(process.status)),
        ],
      ),
    );
  }

  // Aksiyon butonları panelini oluşturan widget
  Widget _buildActionButtonsPanel() {
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 16.0), // ActionButton kendi padding'ine sahip
      color: Theme.of(context).scaffoldBackgroundColor, // Arka plan rengi
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Butonları yukarı yasla
        children: [
          const SizedBox(height: 16), // Üst boşluk
          ActionButton(
            label: 'Gün Başı Yap',
            icon: Icons.play_circle_outline,
            backgroundColor: Colors.green.shade600,
            onPressed: _startDay, // Repository metodunu çağır
          ),
          ActionButton(
            label: 'Gün Sonu Yap',
            icon: Icons.stop_circle_outlined,
            backgroundColor: Colors.red.shade600,
            onPressed: _endDay, // Repository metodunu çağır
          ),
          ActionButton(
            label: 'Kasaya Para Ekle',
            icon: Icons.add_card_outlined, // Daha uygun bir ikon
            backgroundColor: Colors.blueGrey.shade600,
            onPressed: _addCash, // Repository metodunu çağır
          ),
          // Ayarlar butonu Drawer'da olduğu için burada tekrarlamaya gerek yok
          // İstenirse eklenebilir:
          // ActionButton(
          //   label: 'Ayarlar',
          //   icon: Icons.settings,
          //   backgroundColor: Colors.grey.shade600,
          //   onPressed: () => Scaffold.of(context).openEndDrawer(),
          // ),
        ],
      ),
    );
  }
}

// Helper Widget'lar (Sayfaya özel oldukları için burada kalabilirler)

// Tablo Başlık Hücresi
class _TableHeaderCell extends StatelessWidget {
  final String text;
  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ), // Standart padding
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          // Daha uygun stil
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Tablo Veri Hücresi
class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ), // Standart padding
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ), // Tema stili
    );
  }
}
