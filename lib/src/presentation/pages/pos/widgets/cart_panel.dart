// src/presentation/pages/pos/widgets/cart_panel.dart
 import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
 import '../../../state/cart_notifier.dart';
 import 'cart_item_tile.dart'; // CartItemTile'ı import et
 import 'payment_section.dart'; // PaymentSection'ı import et

 class CartPanel extends StatelessWidget {
   final bool isMobileLayout;
   final bool isExpanded; // Sadece mobil için
   final VoidCallback? onExpandToggle; // Sadece mobil için
   final bool isProcessingPayment;
   final String? paymentErrorMessage;
   final ValueChanged<String> onProcessPayment;
   final ValueChanged<double> onPrintReceipt;
   final VoidCallback onClearCart;


   // Private constructor
   const CartPanel._({
     required this.isMobileLayout,
     this.isExpanded = false, // Mobil için default false
     this.onExpandToggle,
     required this.isProcessingPayment,
     this.paymentErrorMessage,
     required this.onProcessPayment,
     required this.onPrintReceipt,
     required this.onClearCart,
   });

   // Desktop/Tablet için fabrika metodu
   factory CartPanel.desktop({
       required bool isProcessingPayment,
       String? paymentErrorMessage,
       required ValueChanged<String> onProcessPayment,
       required ValueChanged<double> onPrintReceipt,
       required VoidCallback onClearCart,
   }) {
       return CartPanel._(
           isMobileLayout: false,
           isProcessingPayment: isProcessingPayment,
           paymentErrorMessage: paymentErrorMessage,
           onProcessPayment: onProcessPayment,
           onPrintReceipt: onPrintReceipt,
           onClearCart: onClearCart,
       );
   }

   // Mobil için fabrika metodu
   factory CartPanel.mobile({
       required bool isExpanded,
       required VoidCallback onExpandToggle,
       required bool isProcessingPayment,
       String? paymentErrorMessage,
       required ValueChanged<String> onProcessPayment,
       required ValueChanged<double> onPrintReceipt,
       required VoidCallback onClearCart,
   }) {
       return CartPanel._(
           isMobileLayout: true,
           isExpanded: isExpanded,
           onExpandToggle: onExpandToggle,
           isProcessingPayment: isProcessingPayment,
           paymentErrorMessage: paymentErrorMessage,
           onProcessPayment: onProcessPayment,
           onPrintReceipt: onPrintReceipt,
           onClearCart: onClearCart,
       );
   }


   @override
   Widget build(BuildContext context) {
       final cartNotifier = context.watch<CartNotifier>(); // Sepet verilerini al
       final theme = Theme.of(context);

       Widget content = Column(
           children: [
                // Sepet Başlığı ve Temizle Butonu (sadece desktop)
                if (!isMobileLayout) _buildDesktopHeader(context, cartNotifier),
                // Sepet İçeriği Listesi
                Expanded(child: _buildCartItemList(cartNotifier)),
                // Ödeme Bölümü
                PaymentSection(
                    totalAmount: cartNotifier.totalAmount,
                    isProcessing: isProcessingPayment,
                    errorMessage: paymentErrorMessage,
                    onProcessPayment: onProcessPayment,
                    onPrintReceipt: () => onPrintReceipt(cartNotifier.totalAmount),
                    onCancel: onClearCart, // İptal butonu sepeti temizlesin
                    canPay: cartNotifier.items.isNotEmpty, // Sepet boşsa ödeme butonları pasif
                ),
           ],
       );

       if (isMobileLayout) {
           // Mobil: Genişletilebilir alt panel
           return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: isExpanded ? MediaQuery.of(context).size.height * 0.5 : 60, // Yükseklik ayarı
                decoration: BoxDecoration(
                    color: theme.cardColor, // Kart rengi
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                    ),
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
                        _buildMobileHeader(context, cartNotifier), // Mobil başlık (genişletme/daraltma)
                        if (isExpanded) Expanded(child: content), // Genişlemişse içeriği göster
                    ],
                ),
           );
       } else {
           // Desktop: Sabit sağ panel
           return Container(
               padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8), // Kenar boşlukları
               color: theme.cardColor, // Arka plan rengi
               child: content,
           );
       }
   }

   // Desktop Başlığı
   Widget _buildDesktopHeader(BuildContext context, CartNotifier cartNotifier) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text('Sepet (${cartNotifier.uniqueItemsCount})', style: Theme.of(context).textTheme.titleLarge),
           if (cartNotifier.items.isNotEmpty)
             IconButton(
               icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
               onPressed: onClearCart, // Sepeti temizleme fonksiyonunu çağır
               tooltip: 'Sepeti Temizle',
             ),
         ],
       ),
     );
   }

   // Mobil Başlık (Genişletme/Daraltma)
    Widget _buildMobileHeader(BuildContext context, CartNotifier cartNotifier) {
     final theme = Theme.of(context);
     return InkWell(
       onTap: onExpandToggle, // Genişletme/Daraltma fonksiyonunu çağır
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         decoration: BoxDecoration(
           color: theme.primaryColor.withOpacity(0.05), // Hafif arka plan
           border: Border(bottom: BorderSide(color: theme.dividerColor)),
         ),
         child: Row(
           children: [
             Icon(
               isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
               color: theme.primaryColor,
             ),
             const SizedBox(width: 8),
             Text('Sepet (${cartNotifier.totalItemsCount})', style: const TextStyle(fontWeight: FontWeight.bold)), // Toplam adet
             const Spacer(),
             Text(
               '${cartNotifier.totalAmount.toStringAsFixed(2)} ₺',
               style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
             ),
           ],
         ),
       ),
     );
   }


   // Sepet Ürün Listesi
   Widget _buildCartItemList(CartNotifier cartNotifier) {
       if (cartNotifier.items.isEmpty) {
       return const Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
             SizedBox(height: 16),
             Text('Sepetiniz boş', style: TextStyle(fontSize: 16, color: Colors.grey)),
           ],
         ),
       );
     }

     return ListView.separated(
       padding: EdgeInsets.zero, // Panelin kendi padding'i var
       itemCount: cartNotifier.items.length,
       separatorBuilder: (context, index) => const Divider(height: 1),
       itemBuilder: (context, index) {
         final item = cartNotifier.items[index];
         // CartItemTile widget'ını kullanıyoruz
         return CartItemTile(
             item: item,
             onIncrease: () => cartNotifier.updateQuantity(item.productId, item.quantity + 1),
             onDecrease: () => cartNotifier.updateQuantity(item.productId, item.quantity - 1),
             onRemove: () => cartNotifier.removeItem(item.productId), // Silme fonksiyonu
         );
       },
     );
   }
 }