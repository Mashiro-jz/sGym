import 'package:flutter/material.dart';

class ModernUserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String firstName;
  final String lastName;
  final double radius;
  final double fontSize;

  const ModernUserAvatar({
    super.key,
    this.photoUrl,
    required this.firstName,
    required this.lastName,
    this.radius = 24.0,
    this.fontSize = 16.0,
  });

  // --- KOLOR Z NASZEGO MOTYWU ---
  final Color _primaryColor = const Color(0xFF00E676);

  @override
  Widget build(BuildContext context) {
    // Bezpieczne pobieranie inicjałów (zapobiega błędom, gdy string jest pusty)
    final String firstInitial = firstName.isNotEmpty ? firstName[0] : "";
    final String lastInitial = lastName.isNotEmpty ? lastName[0] : "";
    final String initials = "$firstInitial$lastInitial".toUpperCase();

    return CircleAvatar(
      radius: radius,
      // Półprzezroczyste neonowe tło (idealnie stapia się z ciemnymi panelami)
      backgroundColor: _primaryColor.withValues(alpha: 0.15),
      // Jaskrawy, neonowy tekst
      foregroundColor: _primaryColor,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initials.isNotEmpty ? initials : "?",
              style: TextStyle(
                fontWeight: FontWeight.w900, // Mocne pogrubienie
                fontSize: fontSize,
                letterSpacing:
                    1.0, // Lekko rozsunięte litery dla lepszego efektu
              ),
            )
          : null,
    );
  }
}
