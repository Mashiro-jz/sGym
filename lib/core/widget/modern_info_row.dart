import 'package:flutter/material.dart';

class ModernInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ModernInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // --- NOWA IKONA (Neon Glow Effect) ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(
              alpha: 0.15,
            ), // Półprzezroczyste neonowe tło
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _primaryColor.withValues(alpha: 0.3),
            ), // Subtelna ramka
          ),
          child: Icon(icon, color: _primaryColor, size: 20), // Neonowa ikona
        ),
        const SizedBox(width: 16),

        // --- TEKSTY ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: _textHintColor, // Szaro-zielony kolor podpowiedzi
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white, // CZYSTA BIEL - idealna czytelność na ciemnym tle!
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
