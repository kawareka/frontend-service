// src/presentation/pages/pos/pos_page.dart
import 'package:flutter/material.dart';
import 'package:gotpos/src/core/utils/app_constants.dart';
import 'package:gotpos/src/domain/repositories/payment_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart'; // Provider'ı import et
import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/table_info.dart'; // Seçilen masa bilgisi için
import '../../../domain/repositories/pos_repository.dart';
import '../../state/cart_notifier.dart'; // CartNotifier'ı import et
// Alt widget'ları import et
import 'widgets/pos_app_bar.dart';
import 'widgets/product_grid.dart';
import 'widgets/cart_panel.dart';
import 'widgets/pos_sidebar.dart';

class POSPage extends StatelessWidget {
  final TableInfo? selectedTable; // Hangi masadan gelindiği bilgisi (opsiyonel)
  final PosRepository posRepository;
  final PaymentRepository paymentRepository;

  const POSPage({
    super.key,
    this.selectedTable,
    required this.posRepository,
    required this.paymentRepository,
  });

  @override
  Widget build(BuildContext context) {
    // CartNotifier'ı bu sayfa ve alt widget'ları için sağlıyoruz
    return ChangeNotifierProvider(
      create: (_) => CartNotifier(),
      child: _POSPageContent(
        selectedTable: selectedTable,
        posRepository: posRepository,
        paymentRepository: paymentRepository,
      ),
    );
  }
}

// Asıl stateful içeriği tutan iç widget
class _POSPageContent extends StatefulWidget {
  final TableInfo? selectedTable;
  final PosRepository posRepository;
  final PaymentRepository paymentRepository;

  const _POSPageContent({
    this.selectedTable,
    required this.posRepository,
    required this.paymentRepository,
  });

  @override
  State<_POSPageContent> createState() => _POSPageContentState();
}

class _POSPageContentState extends State<_POSPageContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _categories = []; // Future tamamlanınca doldurulacak

  // UI State
  bool _isLoading = true; // Başlangıç yükleme durumu
  String? _errorMessage;
  bool _isMobileLayout = false;
  bool _isCartExpanded = false; // Mobil görünümdeki sepet durumu
  bool _isProcessingPayment = false;
  String? _paymentErrorMessage;

  // Son eklenen ürün için SnackBar kontrolü
  String? _lastShownSnackbarProductName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 0,
      vsync: this,
    ); // Başlangıçta 0 sekme
    _loadInitialData();

    // CartNotifier'daki değişiklikleri dinleyerek SnackBar göster
    // initState içinde context.read kullanmak daha güvenli
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartNotifier>().addListener(_showProductAddedSnackbar);
    });
  }

  @override
  void dispose() {
    // Listener'ı temizle
    if (mounted) {
      context.read<CartNotifier>().removeListener(_showProductAddedSnackbar);
    }
    _tabController.dispose();
    super.dispose();
  }

  // SnackBar gösterme fonksiyonu
  void _showProductAddedSnackbar() {
    final cartNotifier = context.read<CartNotifier>();
    final productName = cartNotifier.lastAddedProductNameForSnackbar;

    // Sadece yeni bir ürün adı varsa ve öncekiyle aynı değilse göster
    if (productName != null && productName != _lastShownSnackbarProductName) {
      _lastShownSnackbarProductName = productName; // Gösterilen ismi kaydet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName sepete eklendi'),
          duration: const Duration(seconds: 2), // Süreyi biraz artıralım
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
          action: SnackBarAction(
            label: 'Sepeti Gör',
            onPressed: () {
              if (_isMobileLayout) {
                setState(() => _isCartExpanded = true); // Mobil sepeti aç
              }
              // Desktop modunda bir şey yapmaya gerek yok, sepet zaten görünür
            },
          ),
        ),
      );
      // SnackBar gösterildikten sonra ismi temizleyebiliriz (isteğe bağlı)
      // Future.delayed(Duration(milliseconds: 100), () {
      //   cartNotifier._clearLastSnackbarName();
      // });
    } else if (productName == null) {
      // Eğer isim temizlendiyse, gösterilen ismi de sıfırla
      _lastShownSnackbarProductName = null;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final categories = await widget.posRepository.getCategories();

      if (mounted) {
        // Widget hala aktifse state'i güncelle
        _categories = categories;
        _tabController.dispose(); // Eski controller'ı dispose et
        _tabController = TabController(length: categories.length, vsync: this);
        // Ürünleri Future'dan çıkarıp bir değişkene atayabiliriz
        // veya ProductGrid içinde FutureBuilder kullanmaya devam edebiliriz.
        // Şimdilik Future olarak bırakalım, ProductGrid yönetecek.
        // Future'ı da güncelleyelim

        setState(() => _isLoading = false);

        // İlk ürün eklendiğinde mobil sepeti açma mantığı için:
        // context.read<CartNotifier>().addListener(_checkCartForExpansion);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Veriler yüklenemedi: $e';
        });
      }
    }
  }

  // Ödeme işlemi (CartNotifier'dan veri alacak)
  void _processPayment(String paymentMethod) async {
    //lock screen
    if (_isProcessingPayment) return; // Zaten işlem yapılıyorsa çık
    final cartNotifier = context.read<CartNotifier>();
    if (cartNotifier.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sepet boş, ödeme yapılamaz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _paymentErrorMessage = null;
    });

    // Ödeme işlemi simülasyonu
    if (!mounted) return; // Widget dispose edildiyse işlem yapma

    String orderId = await widget.paymentRepository.createOrderBulk(
      AppConstants.branchId,
      cartNotifier.items.map((item) {
        return Product(
          id: item.productId,
          name: item.name,
          price: item.price,
          quantity: item.quantity,
        );
      }).toList(),
    );
    /*
      widget.paymentRepository
          .processPayment(
            'POS_001_BRANCH_123',
            orderId,
            'CARD',
            123.0, // Ödeme tutarı
          )
          .then((success) {
            if (!success) {
              setState(() {
                _paymentErrorMessage =
                    'Ödeme işlemi başarısız oldu. Lütfen tekrar deneyin.';
              });
              return;
            }
          });
          */
    final isSuccess = orderId.isNotEmpty; // Simülasyon için basit kontrol

    if (isSuccess) {
      // Başarılı ödeme -> Dialog göster ve sepeti temizle
      final total = cartNotifier.totalAmount; // Toplam tutarı al
      cartNotifier.clearCart(); // Sepeti temizle
      _showPaymentSuccessDialog(paymentMethod, total);
    } else {
      // Başarısız ödeme -> Hata mesajı göster
      setState(() {
        _paymentErrorMessage =
            'Ödeme işlemi başarısız oldu. Lütfen tekrar deneyin.';
      });
    }
    setState(() => _isProcessingPayment = false);
  }

  // Başarılı ödeme dialog'u
  void _showPaymentSuccessDialog(String paymentMethod, double totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text('Ödeme Başarılı'), // Stil tema'dan gelecek
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ödeme Türü: $paymentMethod'),
                Text('Toplam Tutar: ${totalAmount.toStringAsFixed(2)} ₺'),
                Text('Tarih: ${DateTime.now().toString().substring(0, 16)}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Sadece kapat
                child: const Text('Tamam'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _printReceipt(
                    paymentMethod,
                    totalAmount,
                  ); // Makbuz yazdırma fonksiyonu
                },
                child: const Text('Makbuz Yazdır'),
              ),
            ],
          ),
    );
  }

  // Makbuz yazdırma simülasyonu
  void _printReceipt(String paymentMethod, double totalAmount) {
    // Gerçek yazdırma işlemi burada yapılacak
    print('--- Makbuz Yazdırılıyor ---');
    print('Ödeme Tipi: $paymentMethod');
    print('Tarih: ${DateTime.now().toString().substring(0, 16)}');
    // Sepet içeriği (notifier temizlendiği için başka bir yerden alınmalı veya temizlenmeden önce saklanmalı)
    print('Toplam Tutar: ${totalAmount.toStringAsFixed(2)} ₺');
    print('---------------------------');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Makbuz yazdırılıyor...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutuna göre layout belirleme
    final screenSize = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // _isMobileLayout = screenSize.shortestSide < 600 || !isLandscape;
    // Tabletleri de desktop gibi kabul edelim, sadece telefonlar mobil olsun:
    _isMobileLayout = screenSize.width < 700; // Genişliğe göre karar verelim

    // CartNotifier'ı dinlemek için Consumer kullanalım (veya context.watch)
    final cartNotifier = context.watch<CartNotifier>();

    return Scaffold(
      // AppBar'ı ayrı bir widget yaptık
      appBar: PosAppBar(
        tabController: _tabController,
        categories: _categories,
        isLoading: _isLoading,
        selectedTableName:
            widget.selectedTable?.name, // Seçilen masa adını gönder
      ),
      // Mobil layout için Drawer
      drawer: _isMobileLayout ? PosSidebar() : null,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildBody(cartNotifier), // Ana içeriği oluşturan metod
    );
  }

  // Cihazın durumuna göre body'yi oluşturan metod
  Widget _buildBody(CartNotifier cartNotifier) {
    if (_isMobileLayout) {
      return _buildMobileLayout(cartNotifier);
    } else {
      return _buildDesktopLayout(cartNotifier);
    }
  }

  // Mobil (Telefon) Layout
  Widget _buildMobileLayout(CartNotifier cartNotifier) {
    return Column(
      children: [
        // Ürünlerin gösterildiği alan (TabBarView)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                _categories.map((category) {
                  // ProductGrid widget'ını kullanıyoruz
                  return ProductGrid(
                    categoryId: category.id,
                    posRepository: widget.posRepository,
                    // Ürün ekleme işlemi için notifier'ı veriyoruz
                    onProductTap:
                        (product) =>
                            context.read<CartNotifier>().addItem(product),
                  );
                }).toList(),
          ),
        ),
        // Genişletilebilir Sepet Paneli
        CartPanel.mobile(
          isExpanded: _isCartExpanded,
          onExpandToggle:
              () => setState(() => _isCartExpanded = !_isCartExpanded),
          // Ödeme işlemi için fonksiyonları ve state'i gönderiyoruz
          isProcessingPayment: _isProcessingPayment,
          paymentErrorMessage: _paymentErrorMessage,
          onProcessPayment: _processPayment,
          onPrintReceipt:
              (total) => _printReceipt(
                'Bilinmiyor',
                total,
              ), // Mobil'de ödeme tipi belli değilse
          onClearCart: () => _showClearCartDialog(context),
        ),
      ],
    );
  }

  // Desktop/Tablet Layout
  Widget _buildDesktopLayout(CartNotifier cartNotifier) {
    return Row(
      children: [
        // Sol Sidebar (Sabit)
        PosSidebar(),
        // Ürünler Alanı (Genişler)
        Expanded(
          flex: 5, // Ürünler daha geniş alan kaplasın
          child: TabBarView(
            controller: _tabController,
            children:
                _categories.map((category) {
                  return ProductGrid(
                    categoryId: category.id,
                    posRepository: widget.posRepository,
                    onProductTap:
                        (product) =>
                            context.read<CartNotifier>().addItem(product),
                  );
                }).toList(),
          ),
        ),
        // Sağ Sepet Paneli (Sabit Genişlik)
        SizedBox(
          width: 400, // Sabit genişlik verelim
          child: CartPanel.desktop(
            isProcessingPayment: _isProcessingPayment,
            paymentErrorMessage: _paymentErrorMessage,
            onProcessPayment: _processPayment,
            onPrintReceipt: (total) => _printReceipt('Bilinmiyor', total),
            onClearCart: () => _showClearCartDialog(context),
          ),
        ),
      ],
    );
  }

  // Sepeti Temizle Onay Dialog'u
  Future<void> _showClearCartDialog(BuildContext context) {
    // Dialog içinde CartNotifier'a erişmek için context.read kullanabiliriz
    final cartNotifier = context.read<CartNotifier>();
    if (cartNotifier.items.isEmpty)
      return Future.value(); // Sepet boşsa gösterme

    return showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Sepeti Temizle'),
            content: const Text(
              'Sepetteki tüm ürünler silinecek. Emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  cartNotifier.clearCart(); // Notifier üzerinden temizle
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Temizle'),
              ),
            ],
          ),
    );
  }
}
