// src/presentation/widgets/action_button.dart
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onPressed; // Devre dışı bırakılabilmesi için nullable

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        // Butonlar arasına boşluk eklemek için vertical padding
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(label), // Stil tema'dan gelecek
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white, // Metin ve ikon rengi
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                4,
              ), // Orijinal köşe yuvarlaklığı
            ),
            // Temadan gelen textStyle'ı kullan ama istersen override edebilirsin
            //TODO: ekorhan
            
            //textStyle: Theme.of(
              //context,
            //).elevatedButtonTheme.style?.textStyle?.copyWith(fontSize: 16),
          ).copyWith(
            // ElevatedButton disabled durumunu otomatik yönetir
            // İstersen özelleştir:
            // disabledBackgroundColor: MaterialStateProperty.all(backgroundColor.withOpacity(0.5)),
            // disabledForegroundColor: MaterialStateProperty.all(Colors.white70),
          ),
        ),
      ),
    );
  }
}
