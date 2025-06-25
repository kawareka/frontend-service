// src/presentation/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:gotpos/src/data/repositories/in_memory_day_process_repository.dart';
import 'package:gotpos/src/data/repositories/in_memory_table_repository.dart';
import '../pages/day_process/day_process_page.dart';
import '../pages/table_selection/table_selection_page.dart';
import '../pages/settings/settings_page.dart';
// Diğer sayfaları ve UserProfileFooter'ı import et
import 'user_profile_footer.dart';
// Servisleri veya Repository'leri import et (Ayarlar sayfası için gerekli)
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/in_memory_settings_repository.dart'; // Geçici olarak direkt implementasyon

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  // Örnek: Basit Dependency Injection (daha iyisi Service Locator olabilir)
  // Bu repository'ler dışarıdan sağlanmalı (örn. main.dart'ta oluşturulup Provider ile iletilmeli)
  final SettingsRepository settingsRepository = InMemorySettingsRepository();

  @override
  Widget build(BuildContext context) {
    // Mevcut rotayı alarak aktif menü öğesini vurgulayabiliriz (isteğe bağlı)
    // final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Container(
        color: Colors.indigo.shade800, // Tema'dan alınabilir
        child: Column(
          children: [
            // Drawer Başlığı
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: Colors.indigo.shade900, // Tema'dan alınabilir
              child: const Row(
                children: [
                  Icon(Icons.point_of_sale, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'GotPOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            // Menü Öğeleri
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(4),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard,
                    label: 'Masalar',
                    targetPage: TableSelectionPage(
                      tableRepository: InMemoryTableRepository(),
                    ), // İsimlendirilmiş rota veya sayfa widget'ı
                    // isActive: currentRoute == AppRoutes.tableSelection, // Aktiflik kontrolü
                  ),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.calendar_today,
                    label: 'Gün İşlemleri',
                    targetPage: DayProcessPage(
                      dayProcessRepository: InMemoryDayProcessRepository(),
                      settingsRepository: InMemorySettingsRepository(),
                    ),
                    // isActive: currentRoute == AppRoutes.dayProcess,
                  ),
                  /*
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.fastfood,
                    label: 'Menü Yönetimi',
                    // onTap: () => print('Menü Yönetimi Tıklandı'), // Henüz sayfası yoksa
                    // Veya doğrudan ayarlar içindeki ilgili kısma yönlendirme?
                  ),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.receipt_long,
                    label: 'Adisyonlar',
                    // onTap: () => print('Adisyonlar Tıklandı'),
                  ),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person,
                    label: 'Müşteriler',
                    // onTap: () => print('Müşteriler Tıklandı'),
                  ),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.assessment,
                    label: 'Raporlar',
                    // onTap: () => print('Raporlar Tıklandı'),
                  ),
                  */
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings,
                    label: 'Ayarlar',
                    // Ayarlar sayfasını SettingsRepository ile oluşturuyoruz
                    targetPage: SettingsPage(
                      settingsRepository: settingsRepository,
                    ),
                    // isActive: currentRoute == AppRoutes.settings,
                  ),
                ],
              ),
            ),
            // Kullanıcı Profili Footer'ı
            UserProfileFooter(
              userName: 'Mehmet Yılmaz', // Bu bilgi login işleminden gelmeli
              userRole: 'Kasiyer', // Bu bilgi login işleminden gelmeli
              onLogout: () {
                // Çıkış işlemi
                print('Oturum Kapat Tıklandı');
                // Navigator.of(context).pushReplacementNamed(AppRoutes.login); // Örneğin
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tek bir Drawer öğesi oluşturma metodu
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    Widget? targetPage, // Gidilecek sayfa widget'ı
    VoidCallback? onTap, // Veya özel bir onTap fonksiyonu
    bool isActive = false, // Aktif öğeyi vurgulamak için (isteğe bağlı)
  }) {
    final color = isActive ? Colors.white : Colors.white70;
    final tileColor = isActive ? Colors.white.withOpacity(0.2) : null;

    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: tileColor,
      onTap: () {
        Navigator.pop(context); // Drawer'ı kapat
        if (targetPage != null) {
          // Mevcut sayfaya tekrar gitmeyi engelle (isteğe bağlı)
          if (ModalRoute.of(context)?.settings.name !=
              targetPage.toStringShort()) {
            Navigator.pushReplacement(
              // Veya push, duruma göre
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          }
        } else if (onTap != null) {
          onTap();
        }
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }
}
