import 'package:flutter/material.dart';

class ModernInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ModernInfoChip(
    this.icon,
    this.label, {
    super.key,
    // Domyślnie używamy naszego szaro-zielonego koloru (pasuje do ciemnego motywu)
    this.color = const Color(0xFF8B9D90),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.15,
        ), // Nieco mocniejsze tło dla lepszego kontrastu
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ), // Delikatna ramka
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight
                  .w900, // Mocniejsze pogrubienie w stylu Dark Fitness
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
