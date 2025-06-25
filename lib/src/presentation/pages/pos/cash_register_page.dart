import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CashRegister extends StatelessWidget {
  const CashRegister({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GotPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Poppins',
        primaryColor: Colors.indigo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const POSScreen(),
    );
  }
}

class Product {
  final String name;
  final double price;
  final String categoryId;
  final IconData icon;

  Product({
    required this.name,
    required this.price,
    required this.categoryId,
    this.icon = Icons.fastfood,
  });
}

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final String categoryId;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.categoryId,
  });

  double get total => quantity * price;
}

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});
  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Category> categories;
  late List<Product> allProducts;
  List<OrderItem> cart = [];
  bool isProcessingPayment = false;
  String? paymentErrorMessage;

  // For tablet specific layout
  bool isMobileLayout = false;
  bool isCartExpanded = false;

  @override
  void initState() {
    super.initState();

    // Initialize categories
    categories = [
      Category(
        id: 'beverage',
        name: 'İçecek',
        color: Colors.blue.shade700,
        icon: Icons.local_drink,
      ),
      Category(
        id: 'food',
        name: 'Yemek',
        color: Colors.blue.shade700,
        icon: Icons.restaurant,
      ),
      Category(
        id: 'dessert',
        name: 'Tatlı',
        color: Colors.blue.shade700,
        icon: Icons.cake,
      ),
      Category(
        id: 'fast_food',
        name: 'Fast Food',
        color: Colors.blue.shade700,
        icon: Icons.fastfood,
      ),
    ];

    // Initialize products
    allProducts = [
      // İçecekler
      Product(
        name: 'Su',
        price: 10.0,
        categoryId: 'beverage',
        icon: Icons.water_drop,
      ),
      Product(
        name: 'Cola',
        price: 45.0,
        categoryId: 'beverage',
        icon: Icons.local_drink,
      ),
      Product(
        name: 'Ayran',
        price: 25.0,
        categoryId: 'beverage',
        icon: Icons.local_cafe,
      ),
      Product(
        name: 'Meyve Suyu',
        price: 35.0,
        categoryId: 'beverage',
        icon: Icons.wine_bar,
      ),
      Product(
        name: 'Türk Kahvesi',
        price: 40.0,
        categoryId: 'beverage',
        icon: Icons.coffee,
      ),
      Product(
        name: 'Çay',
        price: 15.0,
        categoryId: 'beverage',
        icon: Icons.emoji_food_beverage,
      ),

      // Yemekler
      Product(
        name: 'Pizza',
        price: 185.0,
        categoryId: 'food',
        icon: Icons.local_pizza,
      ),
      Product(
        name: 'Balık',
        price: 98.0,
        categoryId: 'food',
        icon: Icons.set_meal,
      ),
      Product(
        name: 'Köfte',
        price: 120.0,
        categoryId: 'food',
        icon: Icons.fastfood,
      ),
      Product(
        name: 'Tavuk Şiş',
        price: 105.0,
        categoryId: 'food',
        icon: Icons.restaurant,
      ),
      Product(
        name: 'Kebap',
        price: 150.0,
        categoryId: 'food',
        icon: Icons.restaurant,
      ),
      Product(
        name: 'Makarna',
        price: 80.0,
        categoryId: 'food',
        icon: Icons.dinner_dining,
      ),

      // Tatlılar
      Product(
        name: 'Baklava',
        price: 120.0,
        categoryId: 'dessert',
        icon: Icons.cake,
      ),
      Product(
        name: 'Sütlaç',
        price: 80.0,
        categoryId: 'dessert',
        icon: Icons.icecream,
      ),
      Product(
        name: 'Künefe',
        price: 110.0,
        categoryId: 'dessert',
        icon: Icons.bakery_dining,
      ),
      Product(
        name: 'Dondurma',
        price: 60.0,
        categoryId: 'dessert',
        icon: Icons.icecream,
      ),

      // Fast Food
      Product(
        name: 'Hamburger',
        price: 130.0,
        categoryId: 'fast_food',
        icon: Icons.lunch_dining,
      ),
      Product(
        name: 'Tost',
        price: 70.0,
        categoryId: 'fast_food',
        icon: Icons.breakfast_dining,
      ),
      Product(
        name: 'Patates Kızartması',
        price: 50.0,
        categoryId: 'fast_food',
        icon: Icons.outdoor_grill,
      ),
    ];

    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get total => cart.fold(0, (sum, item) => sum + item.total);

  void addToCart(Product product) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = cart.indexWhere((item) => item.name == product.name);
      if (index != -1) {
        cart[index] = OrderItem(
          name: cart[index].name,
          quantity: cart[index].quantity + 1,
          price: cart[index].price,
          categoryId: cart[index].categoryId,
        );
      } else {
        cart.add(
          OrderItem(
            name: product.name,
            quantity: 1,
            price: product.price,
            categoryId: product.categoryId,
          ),
        );
      }

      // Tablet modunda sepeti otomatik göster
      if (isMobileLayout && !isCartExpanded && cart.length == 1) {
        isCartExpanded = true;
      }
    });

    // Animasyonlu bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
        action: SnackBarAction(
          label: 'Sepeti Gör',
          onPressed: () {
            if (isMobileLayout) {
              setState(() {
                isCartExpanded = true;
              });
            }
          },
        ),
      ),
    );
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index] = OrderItem(
          name: cart[index].name,
          quantity: newQuantity,
          price: cart[index].price,
          categoryId: cart[index].categoryId,
        );
      }
    });
  }

  void clearCart() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sepeti Temizle'),
            content: const Text(
              'Sepetteki tüm ürünler silinecek. Emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    cart.clear();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Temizle'),
              ),
            ],
          ),
    );
  }

  void processPayment(String paymentMethod) {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sepet boş, ödeme yapılamaz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isProcessingPayment = true;
      paymentErrorMessage = null;
    });

    // Ödeme işlemi simülasyonu
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isProcessingPayment = false;

        // Demo amaçlı rastgele başarılı/başarısız ödeme
        if (DateTime.now().millisecond % 5 == 0) {
          paymentErrorMessage =
              'Ödeme işlemi başarısız oldu. Lütfen tekrar deneyin.';
        } else {
          // Başarılı ödeme
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ödeme Başarılı',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ödeme Türü: $paymentMethod'),
                      Text('Toplam Tutar: ${total.toStringAsFixed(2)} ₺'),
                      Text(
                        'Tarih: ${DateTime.now().toString().substring(0, 16)}',
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Sepeti temizle
                        setState(() {
                          cart.clear();
                        });
                      },
                      child: const Text('Tamam'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Sepeti temizle ve makbuz yazdır
                        setState(() {
                          cart.clear();
                        });
                        printReceipt();
                      },
                      child: const Text('Makbuz Yazdır'),
                    ),
                  ],
                ),
          );
        }
      });
    });
  }

  void printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Makbuz yazdırılıyor...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutuna göre düzen değişikliği
    final screenSize = MediaQuery.of(context).size;
    final isTabletSize = screenSize.shortestSide < 600;

    // Tablet için yatay mod kontrolü
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Tablet modunda ve yatay modda değilse mobile layout kullan
    isMobileLayout = isTabletSize && !isLandscape;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.indigo.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Geri butonu
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 60.0,
              ),
              onPressed: () {
                Navigator.pop(context); // Geri gitme işlevi
              },
              padding: const EdgeInsets.only(
                left: 0,
                right: 16.0,
              ), // Sol kenara yapışık
            ),
            // TabBar (kategoriler)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 80.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.indigo.shade100,
                  indicatorColor: Colors.white,
                  tabAlignment: TabAlignment.startOffset,
                  dividerColor: Colors.indigo.shade900,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 22.0),
                  tabs:
                      categories.map((category) {
                        return Tab(
                          icon: Icon(category.icon, size: 28.0),
                          text: category.name,
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading:
            false, // Varsayılan leading'i devre dışı bırak
      ),
      body: isMobileLayout ? _buildMobileLayout() : _buildDesktopLayout(),
      drawer: isMobileLayout ? buildSidebar(context) : null,
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                categories.map((category) {
                  return _buildProductGrid(category);
                }).toList(),
          ),
        ),

        // Tablet modunda genişletilebilir sepet
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height:
              isCartExpanded ? MediaQuery.of(context).size.height * 0.4 : 56,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sepet Başlık Çubuğu
              InkWell(
                onTap: () {
                  setState(() {
                    isCartExpanded = !isCartExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCartExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sepet (${cart.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${total.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sepet İçeriği
              if (isCartExpanded) Expanded(child: _buildCartContent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        buildSidebar(context),

        // Ürünler
        Expanded(
          flex: 5,
          child: TabBarView(
            controller: _tabController,
            children:
                categories.map((category) {
                  return _buildProductGrid(category);
                }).toList(),
          ),
        ),

        // Sepet
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sepet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (cart.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: clearCart,
                        tooltip: 'Sepeti Temizle',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildCartContent()),
                _buildPaymentSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(Category category) {
    final products =
        allProducts.where((p) => p.categoryId == category.id).toList();

    return products.isEmpty
        ? const Center(child: Text('Bu kategoride ürün bulunamadı'))
        : GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _calculateGridColumns(),
            childAspectRatio: 1.05,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
  }

  int _calculateGridColumns() {
    final width = MediaQuery.of(context).size.width;
    if (isMobileLayout) {
      return width > 600 ? 3 : 2;
    } else {
      return width > 1200 ? 4 : 3;
    }
  }

  Widget _buildProductCard(Product product) {
    final category = categories.firstWhere((c) => c.id == product.categoryId);

    return Card(
      elevation: 2,
      shadowColor: category.color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: category.color.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: () => addToCart(product),
        borderRadius: BorderRadius.circular(12),
        splashColor: category.color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(product.icon, size: 32, color: category.color),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${product.price.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    color: category.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sepetiniz boş',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // İlk kategoriye geç
                _tabController.animateTo(0);
              },
              child: const Text('Alışverişe Başla'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cart.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = cart[index];
        final category = categories.firstWhere((c) => c.id == item.categoryId);

        return Dismissible(
          key: Key('cart_item_${item.name}_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              cart.removeAt(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} sepetten çıkarıldı'),
                action: SnackBarAction(
                  label: 'Geri Al',
                  onPressed: () {
                    setState(() {
                      cart.insert(index, item);
                    });
                  },
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withOpacity(0.2),
              child: Text(
                '${item.quantity}',
                style: TextStyle(
                  color: category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${item.price.toStringAsFixed(2)} ₺',
              style: TextStyle(color: Colors.grey[600]),
            ),
            // _buildCartContent fonksiyonundaki ilgili kısım
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.total.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap:
                            () => updateCartItemQuantity(
                              index,
                              item.quantity - 1,
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(
                            12,
                          ), // Padding'i artırdık
                          child: const Icon(
                            Icons.remove,
                            size: 24,
                          ), // Icon boyutunu ayarladık
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap:
                            () => updateCartItemQuantity(
                              index,
                              item.quantity + 1,
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(
                            12,
                          ), // Padding'i artırdık
                          child: const Icon(
                            Icons.add,
                            size: 24,
                          ), // Icon boyutunu ayarladık
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(thickness: 1),

        // Hata mesajı (varsa)
        if (paymentErrorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    paymentErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

        // Toplam
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${total.toStringAsFixed(2)} ₺',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // İşlem Butonları
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 60, // Increased height
                child: OutlinedButton.icon(
                  onPressed: cart.isEmpty ? null : printReceipt,
                  icon: const Icon(
                    Icons.print,
                    size: 24,
                  ), // Increased icon size
                  label: const Text(
                    'Yazdır',
                    style: TextStyle(fontSize: 18),
                  ), // Increased text size
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 60, // Increased height
                child: OutlinedButton.icon(
                  onPressed: cart.isEmpty ? null : () => clearCart(),
                  icon: const Icon(
                    Icons.close,
                    size: 24,
                  ), // Increased icon size
                  label: const Text(
                    'İptal',
                    style: TextStyle(fontSize: 18),
                  ), // Increased text size
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Ödeme Butonları
        if (isProcessingPayment)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60, // Increased height
                  child: OutlinedButton.icon(
                    onPressed:
                        cart.isEmpty ? null : () => processPayment('Nakit'),
                    icon: const Icon(
                      Icons.money,
                      size: 24,
                    ), // Increased icon size
                    label: const Text(
                      'Nakit',
                      style: TextStyle(fontSize: 18),
                    ), // Increased text size
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 60, // Increased height
                  child: OutlinedButton.icon(
                    onPressed:
                        cart.isEmpty
                            ? null
                            : () => processPayment('Kredi Kartı'),
                    icon: const Icon(
                      Icons.credit_card,
                      size: 24,
                    ), // Increased icon size
                    label: const Text(
                      'Kredi Kartı',
                      style: TextStyle(fontSize: 18),
                    ), // Increased text size
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Yan menü (Sidebar)
  Widget buildSidebar(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          // Bu satırı ekleyin
          borderRadius: BorderRadius.zero, // Köşeleri tamamen düz yapar
        ),
        elevation: 0,

        child: Container(
          color: Colors.indigo.shade800,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                color: Colors.indigo.shade900,
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

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(4),
                  children: [
                    // Menü Öğeleri
                    _buildSidebarItem(Icons.table_bar, 'Masa Değiştir'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.receipt_long, 'Adisyon Ekle'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.note_add, 'Adisyon Notu'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.person, 'Müşteri Seç'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.group, 'Grup Seç'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.call_split, 'Adisyon Ayır'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.payment, 'Ödeme Tipi'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.print, 'Hesap Yazdır'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.settings, 'Ayarlar'),
                    const Divider(color: Colors.white24),
                    _buildSidebarItem(Icons.help_outline, 'Yardım'),
                  ],
                ),
              ),

              // Alt menü (Oturum vs.)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade900,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kasiyer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Mehmet Yılmaz',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Çıkış işlemi
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Oturumu Kapat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 24),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 22),
      ),
      onTap: () {
        // Menü öğesi işlemi
        if (isMobileLayout) {
          Navigator.pop(context); // Tablet modunda drawer'ı kapat
        }

        // İşlemi yap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label seçildi'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }
}
