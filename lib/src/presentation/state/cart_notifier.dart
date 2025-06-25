// src/presentation/state/cart_notifier.dart
import 'package:flutter/foundation.dart'; // ChangeNotifier için
import 'package:flutter/services.dart'; // HapticFeedback için
import '../../domain/entities/order_item.dart';
import '../../domain/entities/product.dart';

class CartNotifier extends ChangeNotifier {
  final List<OrderItem> _items = [];
  String? _lastAddedProductNameForSnackbar; // SnackBar için ayrı state

  // Dışarıya değiştirilemez liste verelim (güvenlik için)
  List<OrderItem> get items => List.unmodifiable(_items);

  // Sepetteki toplam ürün adedi (quantity'leri toplayarak)
  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Sepetteki benzersiz ürün sayısı (satır sayısı)
  int get uniqueItemsCount => _items.length;

  // Sepetin toplam tutarı
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.total);

  // SnackBar'da gösterilecek son ürün adı
  String? get lastAddedProductNameForSnackbar =>
      _lastAddedProductNameForSnackbar;

  // Sepete ürün ekleme veya miktar artırma
  void addItem(Product product) {
    HapticFeedback.lightImpact(); // Dokunsal geri bildirim

    final index = _items.indexWhere((item) => item.productId == product.id);

    if (index != -1) {
      // Ürün zaten sepette, miktarını artır
      final existingItem = _items[index];
      // Fiyatın ürün detayından güncel alınması daha doğru olabilir
      // Ama sipariş anındaki fiyatı korumak da bir seçenek olabilir. Şimdilik mevcut fiyatı koruyoruz.
      _items[index] = OrderItem(
        productId: existingItem.productId,
        name: existingItem.name,
        quantity: existingItem.quantity + 1,
        price: existingItem.price,
      );
    } else {
      // Yeni ürün ekle
      _items.add(
        OrderItem(
          productId: product.id,
          name: product.name,
          quantity: 1,
          price: product.price,
        ),
      );
    }
    // SnackBar için ürün adını ayarla ve dinleyicileri uyar
    _lastAddedProductNameForSnackbar = product.name;
    notifyListeners();
    // SnackBar gösterildikten sonra bu ismi temizlemek gerekebilir
  }

  // Sepetteki ürün miktarını güncelleme
  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (newQuantity > 0) {
        // Miktarı güncelle
        final existingItem = _items[index];
        _items[index] = OrderItem(
          productId: existingItem.productId,
          name: existingItem.name,
          quantity: newQuantity,
          price: existingItem.price,
        );
      } else {
        // Miktar 0 veya daha az ise ürünü sepetten kaldır
        _items.removeAt(index);
      }
      //_clearLastAddedSnackbarName(); // Miktar değişince snackbar ismini temizle
      notifyListeners();
    }
  }

  // Ürünü tamamen sepetten kaldırma
  void removeItem(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      _items.removeAt(index);
      _clearLastSnackbarName();
      notifyListeners();
    }
  }

  // Sepeti tamamen temizleme
  void clearCart() {
    if (_items.isNotEmpty) {
      _items.clear();
      _clearLastSnackbarName();
      notifyListeners();
    }
  }

  // SnackBar için kullanılan ismi temizleme metodu
  void _clearLastSnackbarName() {
    if (_lastAddedProductNameForSnackbar != null) {
      _lastAddedProductNameForSnackbar = null;
      // Burada notifyListeners() çağırmaya gerek yok, çünkü bu sadece snackbar içindi.
      // Ancak anlık tepki isteniyorsa çağrılabilir.
    }
  }
}
