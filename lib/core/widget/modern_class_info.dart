import 'package:flutter/material.dart';

class ModernInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  // POPRAWIONY KONSTRUKTOR:
  // icon i label są pozycyjne (bez klamerek), a color jest nazwany (w klamerkach) z domyślną wartością
  const ModernInfoChip(
    this.icon,
    this.label, {
    super.key,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
