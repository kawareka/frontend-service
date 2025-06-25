// src/presentation/pages/pos/widgets/pos_sidebar.dart
import 'package:flutter/material.dart';
import 'package:gotpos/src/data/repositories/in_memory_settings_repository.dart';
import 'package:gotpos/src/domain/repositories/settings_repository.dart';
import 'package:gotpos/src/presentation/pages/settings/settings_page.dart';
import '../../../widgets/user_profile_footer.dart'; // Ortak footer'ı kullan

class PosSidebar extends StatelessWidget {
  PosSidebar({super.key});
  final SettingsRepository settingsRepository = InMemorySettingsRepository();

  @override
  Widget build(BuildContext context) {
    // Desktop layout'ta Drawer yerine doğrudan Container kullanıyoruz
    // Mobil layout'ta ise bu widget Drawer içinde kullanılabilir
    bool isDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;

    return Container(
      width: 240, // Sabit genişlik
      color:
          Theme.of(context).brightness == Brightness.light
              ? Colors.indigo.shade800
              : Colors.grey.shade900, // Tema'ya göre renk
      child: Column(
        children: [
          // Sidebar Başlığı (Opsiyonel, AppBar'da var)
          // Container( ... ),

          // Menü Öğeleri
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(4),
              children: [
                // Menü Öğeleri (icon, label, onTap)
                _buildSidebarItem(
                  context,
                  Icons.swap_horiz_outlined,
                  'Masa Değiştir',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.playlist_add_outlined,
                  'Adisyon Ekle',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.note_add_outlined,
                  'Adisyon Notu',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.person_outline,
                  'Müşteri Seç',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.group_outlined,
                  'Grup Seç',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.call_split_outlined,
                  'Adisyon Ayır',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.payment_outlined,
                  'Ödeme Tipi',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.print_outlined,
                  'Hesap Yazdır',
                  isDrawer: isDrawer,
                ), // Zaten ödeme bölümünde var?
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.settings_outlined,
                  'Ayarlar',
                  isDrawer: isDrawer,
                ),
                const Divider(color: Colors.white24),
                _buildSidebarItem(
                  context,
                  Icons.help_outline,
                  'Yardım',
                  isDrawer: isDrawer,
                ),
              ],
            ),
          ),

          // Alt Kullanıcı Profili Footer'ı
          UserProfileFooter(
            userName: 'Mehmet Yılmaz', // Login'den gelmeli
            userRole: 'Kasiyer', // Login'den gelmeli
            onLogout: () {
              print('Oturum Kapat Tıklandı');
              // Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  // Tek bir Sidebar öğesi oluşturma metodu
  Widget _buildSidebarItem(
    BuildContext context,
    IconData icon,
    String label, {
    required bool isDrawer,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 24),
      title: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ), // Stil
      ),
      onTap: () {
        // Eğer mobil Drawer içindeysek, önce kapat
        if (isDrawer) {
          Navigator.pop(context);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    SettingsPage(settingsRepository: settingsRepository),
          ),
        );
        // TODO: Gerçek aksiyonları buraya ekle (örn: Navigator.push, state güncelleme vb.)
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ), // Dikey padding'i artırdık
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }
}
