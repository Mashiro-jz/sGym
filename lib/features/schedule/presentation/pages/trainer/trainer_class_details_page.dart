import 'package:agym/core/config/injection_container.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TrainerClassDetailsPage extends StatefulWidget {
  final GymClass gymClass;
  const TrainerClassDetailsPage({required this.gymClass, super.key});

  @override
  State<TrainerClassDetailsPage> createState() =>
      _TrainerClassDetailsPageState();
}

class _TrainerClassDetailsPageState extends State<TrainerClassDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final date = widget.gymClass.startTime;
    final String dateText = DateFormat('dd.MM.yyyy').format(date);
    final String timeText = DateFormat('HH:mm').format(date);

    // 1. OWIJAMY CAŁOŚĆ W BLOC PROVIDER
    // Dzięki temu Cubit żyje tylko tak długo, jak ta strona jest otwarta.
    return BlocProvider(
      create: (context) =>
          sl<ClassParticipantsCubit>()
            ..loadParticipants(widget.gymClass.registeredUserIds),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Szczegóły Zajęć"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEKCJA 1: NAGŁÓWEK ZAJĘĆ (Bez zmian) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.05),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.gymClass.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.gymClass.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // --- SEKCJA 2: LISTA UCZESTNIKÓW (Dynamiczna) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Uczestnicy",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // Opcjonalnie: Licznik z danych lokalnych (szybki podgląd)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      "${widget.gymClass.registeredUserIds.length} osób",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. BLOC BUILDER ZAMIAST LISTY
            Expanded(
              child:
                  BlocBuilder<ClassParticipantsCubit, ClassParticipantsState>(
                    builder: (context, state) {
                      // --- STAN 1: ŁADOWANIE ---
                      if (state is ClassParticipantsLoaded) {
                        if (state.participants.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.participants.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final user = state.participants[index];

                            // Logika wyświetlania danych
                            final String fullName =
                                "${user.firstName} ${user.lastName}";
                            final String initials =
                                "${user.firstName[0]}${user.lastName[0]}"
                                    .toUpperCase();

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),

                              // 1. AWATAR (Zdjęcie lub Inicjały)
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blueAccent.shade100,
                                foregroundColor: Colors.blueAccent.shade700,
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? Text(
                                        initials,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),

                              // 2. IMIĘ I NAZWISKO
                              title: Text(
                                fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              // 3. TELEFON (Z ikoną)
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),

                              // 4. IKONA INFO (Sugeruje więcej opcji)
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  _showUserDetails(
                                    context,
                                    user,
                                  ); // Funkcja poniżej
                                },
                              ),

                              // Kliknięcie w cały wiersz też pokazuje szczegóły
                              onTap: () => _showUserDetails(context, user),
                            );
                          },
                        );
                      }

                      return const SizedBox(); // Stan początkowy
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "Brak zapisanych uczestników",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Zajmuje tylko tyle miejsca ile trzeba
            children: [
              // Nagłówek wizytówki
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            "${user.firstName[0]}${user.lastName[0]}",
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.userRole.displayName,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Szczegółowe dane
              _buildInfoRow(Icons.email, "Email", user.email),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.phone, "Telefon", user.phoneNumber),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.person, "Płeć", user.sexRole.displayName),
              const SizedBox(height: 16),

              // Przycisk zamknięcia
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Zamknij"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Pomocniczy widget do wierszy w wizytówce
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
