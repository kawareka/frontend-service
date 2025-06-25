// src/presentation/pages/table_selection/table_selection_page.dart
import 'package:flutter/material.dart';
import 'package:gotpos/src/data/repositories/in_memory_pos_repository.dart';
import 'package:gotpos/src/data/repositories/in_memory_payment_repository.dart';
import '../../../domain/entities/table_info.dart';
import '../../../domain/repositories/table_repository.dart';
import '../../widgets/app_drawer.dart';
import '../pos/pos_page.dart'; // POS sayfasına yönlendirme için

class TableSelectionPage extends StatefulWidget {
  final TableRepository tableRepository;

  const TableSelectionPage({
    super.key,
    required this.tableRepository, // DI hazırlığı
  });

  @override
  State<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  late Future<List<TableInfo>> _tablesFuture;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  void _loadTables() {
    setState(() {
      _tablesFuture = widget.tableRepository.getTables();
    });
  }

  // Masa durumuna göre renk (domain entity'den alınabilir veya burada tanımlanabilir)
  Color _getTableColor(TableStatus status, BuildContext context) {
    switch (status) {
      case TableStatus.empty:
        // Temadan ana rengi almak daha esnek olabilir
        return Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.8); // Indigo yerine
      case TableStatus.occupied:
        return Colors.grey.shade600;
    }
  }

  void _navigateToPosScreen(TableInfo selectedTable) async {
    print('Masa seçildi: ${selectedTable.name}');
    final posRepository = await InMemoryPosRepository.create();
    // POSScreen'e seçilen masa bilgisiyle git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => POSPage(
              selectedTable: selectedTable,
              posRepository: posRepository,
              paymentRepository: InMemoryPaymentRepository(),
            ), // POSPage'e masa bilgisini gönder
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GotPOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTables,
            tooltip: 'Yenile',
          ),
          // Ayarlar butonu Drawer'da mevcut
          const SizedBox(width: 16),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context), // Başlık ve legend kısmı
            const SizedBox(height: 16),
            Expanded(
              child: _buildTableGrid(), // Masa grid'i
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Masalar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary, // Tema rengi
          ),
        ),
        Row(
          children: [
            _LegendItem(
              label: 'Boş',
              color: _getTableColor(TableStatus.empty, context),
            ),
            const SizedBox(width: 16),
            _LegendItem(
              label: 'Dolu',
              color: _getTableColor(TableStatus.occupied, context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableGrid() {
    return FutureBuilder<List<TableInfo>>(
      future: _tablesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Masa bulunamadı.'));
        }

        final tables = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // Ekran boyutuna göre ayarlanabilir
            childAspectRatio: 1.0, // Kare oran
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            return _TableCard(
              table: table,
              color: _getTableColor(table.status, context),
              onTap: () => _navigateToPosScreen(table), // POS'a yönlendir
            );
          },
        );
      },
    );
  }
}

// --- Helper Widget'lar ---

// Masa Kartı Widget'ı
class _TableCard extends StatelessWidget {
  final TableInfo table;
  final Color color;
  final VoidCallback onTap;

  const _TableCard({
    required this.table,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1,
          ), // Hafif border
          boxShadow: [
            // Hafif gölge efekti
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            table.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20, // Font boyutu tema'dan alınabilir
            ),
          ),
        ),
      ),
    );
  }
}

// Renk Açıklama (Legend) Widget'ı
class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.black26, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
