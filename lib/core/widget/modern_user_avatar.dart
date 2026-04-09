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

  @override
  Widget build(BuildContext context) {
    // Bezpieczne pobieranie inicjałów (zapobiega błędom, gdy string jest pusty)
    final String firstInitial = firstName.isNotEmpty ? firstName[0] : "";
    final String lastInitial = lastName.isNotEmpty ? lastName[0] : "";
    final String initials = "$firstInitial$lastInitial".toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white, // Czysta biel z mockupu
      foregroundColor: Colors.deepPurple, // Fioletowe litery z mockupu
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initials.isNotEmpty ? initials : "?",
              style: TextStyle(
                fontWeight: FontWeight.w900, // Mocne pogrubienie
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            )
          : null,
    );
  }
}
