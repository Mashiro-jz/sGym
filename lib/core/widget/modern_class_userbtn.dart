import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ModernUserButton extends StatelessWidget {
  final BuildContext context;
  final GymClass gymClass;
  final bool isRegistered;
  final bool isFull;
  final bool hasStarted;

  const ModernUserButton(
    this.context,
    this.gymClass,
    this.isRegistered,
    this.isFull,
    this.hasStarted, {
    super.key,
  });

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    if (hasStarted) {
      return Text(
        "Zakończone",
        style: TextStyle(
          color: _textHintColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (isRegistered) {
      return OutlinedButton(
        onPressed: () =>
            context.read<ScheduleCubit>().signOutFromClassActivity(gymClass),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text(
          "Wypisz się",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (isFull) {
      return const Text(
        "Brak miejsc",
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }

    return ElevatedButton(
      onPressed: () =>
          context.read<ScheduleCubit>().signUpForClassActivity(gymClass),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.black, // Mocny kontrast dla neonu
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: const Text(
        "Zapisz się",
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
