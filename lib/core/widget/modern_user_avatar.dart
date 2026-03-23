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
    final String initials = "${firstName[0]}${lastName[0]}".toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.deepPurple.shade50,
      foregroundColor: Colors.deepPurple.shade700,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initials,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            )
          : null,
    );
  }
}
