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

  @override
  Widget build(BuildContext context) {
    if (hasStarted) {
      return Text(
        "Zakończone",
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      );
    }

    if (isRegistered) {
      return OutlinedButton(
        onPressed: () =>
            context.read<ScheduleCubit>().signOutFromClassActivity(gymClass),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text("Wypisz się"),
      );
    }

    if (isFull) {
      return const Text(
        "Brak miejsc",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    return FilledButton(
      onPressed: () =>
          context.read<ScheduleCubit>().signUpForClassActivity(gymClass),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        visualDensity: VisualDensity.compact,
      ),
      child: const Text("Zapisz się"),
    );
  }
}
