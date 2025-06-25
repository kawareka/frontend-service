// src/presentation/pages/pos/widgets/cart_item_tile.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/order_item.dart';

class CartItemTile extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove; // Ürünü tamamen silme

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dismissible ile yana kaydırarak silme özelliği
    return Dismissible(
      key: Key('cart_item_${item.productId}'), // Benzersiz key
      direction: DismissDirection.endToStart, // Sadece sağdan sola kaydırma
      onDismissed:
          (direction) => onRemove(), // Kaydırılınca silme fonksiyonunu çağır
      background: Container(
        // Kaydırma arka planı
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error, // Kırmızı arka plan
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: ListTile(
        // Leading yerine direkt isim ve fiyat
        // leading: CircleAvatar(
        //   backgroundColor: itemColor.withOpacity(0.2),
        //   child: Text('${item.quantity}', style: TextStyle(color: itemColor, fontWeight: FontWeight.bold)),
        // ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${item.price.toStringAsFixed(2)} ₺ / adet',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Miktar Artırma/Azaltma Butonları
            _buildQuantityControl(context),
            const SizedBox(width: 16),
            // Toplam Fiyat
            SizedBox(
              width: 80, // Sabit genişlik
              child: Text(
                '${item.total.toStringAsFixed(2)} ₺',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right, // Sağa yasla
              ),
            ),
          ],
        ),
        dense: true, // Daha kompakt görünüm
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ), // Padding ayarı
      ),
    );
  }

  // Miktar kontrol butonlarını oluşturan helper widget
  Widget _buildQuantityControl(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
        children: [
          // Azaltma Butonu
          InkWell(
            onTap: onDecrease,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: Icon(
                Icons.remove,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          // Miktar Göstergesi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Artırma Butonu
          InkWell(
            onTap: onIncrease,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
