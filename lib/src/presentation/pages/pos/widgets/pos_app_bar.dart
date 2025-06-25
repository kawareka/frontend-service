// src/presentation/pages/pos/widgets/pos_app_bar.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/category.dart';

class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<Category> categories;
  final bool isLoading;
  final String? selectedTableName;

  const PosAppBar({
    super.key,
    required this.tabController,
    required this.categories,
    required this.isLoading,
    this.selectedTableName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText =
        selectedTableName != null ? 'Masa: $selectedTableName' : 'GotPOS';

    return AppBar(
      toolbarHeight: 100, // Yükseklik sabit
      // backgroundColor: theme.appBarTheme.backgroundColor, // Tema'dan
      title: Row(
        children: [
          // Geri butonu sadece sayfa stack'inde geri gidilecek yer varsa görünür
          // Navigator.canPop(context) ? BackButton(color: Colors.white) : SizedBox(),
          // Veya her zaman göster:
          BackButton(
            color: Colors.white,
            style: ButtonStyle(
              iconSize: MaterialStateProperty.all(40.0),
            ), // Boyut
          ),
          const SizedBox(width: 20),
          Text(
            titleText,
            style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 30),
          ), // Başlık
          const Spacer(), // Kategori tablarını sağa itemek için (opsiyonel)
        ],
      ),
      bottom:
          isLoading || categories.isEmpty
              ? const PreferredSize(
                // Yüklenirken veya kategori yoksa boşluk bırak
                preferredSize: Size.fromHeight(48.0), // TabBar yüksekliği kadar
                child: SizedBox(
                  height: 48.0,
                  child: Center(child: LinearProgressIndicator()),
                ),
              )
              : TabBar(
                controller: tabController,
                isScrollable: true,
                // labelColor, unselectedLabelColor, indicatorColor tema'dan gelecek
                tabAlignment: TabAlignment.start, // Sola yasla
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Kenar boşlukları
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ), // Tab iç boşlukları
                // labelStyle, unselectedLabelStyle tema'dan gelecek
                tabs:
                    categories.map((category) {
                      return Tab(
                        icon: Icon(category.icon, size: 28.0),
                        text: category.name,
                        // height: 60, // Yükseklik (isteğe bağlı)
                      );
                    }).toList(),
              ),
      automaticallyImplyLeading: false, // Geri butonunu manuel ekledik
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0 + 48.0); // Toplam yükseklik (Toolbar + TabBar)
}
