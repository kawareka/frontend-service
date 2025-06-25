// src/presentation/pages/pos/widgets/payment_section.dart
import 'package:flutter/material.dart';

class PaymentSection extends StatelessWidget {
  final double totalAmount;
  final bool isProcessing;
  final String? errorMessage;
  final ValueChanged<String> onProcessPayment;
  final VoidCallback onPrintReceipt; // Yazdır butonu için
  final VoidCallback onCancel; // İptal butonu için
  final bool canPay; // Ödeme butonlarının aktif olup olmadığını kontrol eder

  const PaymentSection({
    super.key,
    required this.totalAmount,
    required this.isProcessing,
    this.errorMessage,
    required this.onProcessPayment,
    required this.onPrintReceipt,
    required this.onCancel,
    required this.canPay, // Yeni parametre
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonHeight = 50.0; // Buton yüksekliği
    final buttonTextStyle = theme.textTheme.titleMedium?.copyWith(
      color: Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
      children: [
        const Divider(thickness: 1, height: 1), // Ayırıcı çizgi
        // Hata mesajı (varsa)
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ),

        // Toplam Tutar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam:',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${totalAmount.toStringAsFixed(2)} ₺',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Yazdır ve İptal Butonları
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: OutlinedButton.icon(
                  // Sepet boşsa veya işlem yapılıyorsa pasif
                  onPressed: (!canPay || isProcessing) ? null : onPrintReceipt,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Yazdır'),
                  // Stil tema'dan gelebilir
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: OutlinedButton.icon(
                  // Sepet boşsa veya işlem yapılıyorsa pasif
                  onPressed: (!canPay || isProcessing) ? null : onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('İptal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Ödeme Butonları veya Yükleme Göstergesi
        isProcessing
            ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: CircularProgressIndicator(),
              ),
            )
            : Row(
              children: [
                // Nakit Ödeme Butonu
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed:
                          canPay
                              ? () => onProcessPayment('Nakit')
                              : null, // Sepet boşsa null
                      icon: const Icon(Icons.money_outlined),
                      label: Text('Nakit', style: buttonTextStyle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Kredi Kartı Ödeme Butonu
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed:
                          canPay
                              ? () => onProcessPayment('Kredi Kartı')
                              : null, // Sepet boşsa null
                      icon: const Icon(Icons.credit_card_outlined),
                      label: Text('Kredi Kartı', style: buttonTextStyle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }
}
