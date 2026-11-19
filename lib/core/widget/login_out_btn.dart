import 'package:sgym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginOutButton extends StatelessWidget {
  const LoginOutButton({super.key});

  // --- PALETA KOLORĂ“W Z MOCKUPU ---
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _textHintColor = const Color(0xFF8B9D90);
  final Color _borderColor = const Color(0xFF2A3D2D);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      tooltip: "Wyloguj siÄ™",
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: _surfaceColor, // Ciemnozielone tĹ‚o okienka
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
                "Czy na pewno chcesz siÄ™ wylogowaÄ‡ z aplikacji?",
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
                    ), // PĂłĹ‚przezroczysta czerwieĹ„
                    foregroundColor: Colors.redAccent, // Czerwony tekst
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Wyloguj siÄ™",
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
