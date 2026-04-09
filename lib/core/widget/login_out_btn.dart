import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginOutButton extends StatelessWidget {
  const LoginOutButton({super.key});

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _textHintColor = const Color(0xFF8B9D90);
  final Color _borderColor = const Color(0xFF2A3D2D);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      tooltip: "Wyloguj się",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: _surfaceColor, // Ciemnozielone tło okienka
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: _borderColor), // Subtelna ramka
              ),
              title: const Text(
                "Wylogowanie",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Czy na pewno chcesz się wylogować z aplikacji?",
                style: TextStyle(color: _textHintColor, fontSize: 15),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Anuluj",
                    style: TextStyle(
                      color: _textHintColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthCubit>().logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(
                      alpha: 0.15,
                    ), // Półprzezroczysta czerwień
                    foregroundColor: Colors.redAccent, // Czerwony tekst
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Wyloguj się",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
