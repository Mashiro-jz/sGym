import 'package:agym/core/config/injection_container.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_state.dart';
// Importujemy nasze nowe uniwersalne widżety!
import 'package:agym/core/widget/modern_user_avatar.dart';
import 'package:agym/core/widget/modern_info_row.dart';
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

    return BlocProvider(
      create: (context) =>
          sl<ClassParticipantsCubit>()
            ..loadParticipants(widget.gymClass.registeredUserIds),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50, // Jasne tło aplikacji
        appBar: AppBar(
          title: const Text(
            "Szczegóły Zajęć",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEKCJA 1: NAGŁÓWEK ZAJĘĆ ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.gymClass.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // --- SEKCJA 2: LISTA UCZESTNIKÓW ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Uczestnicy",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child:
                  BlocBuilder<ClassParticipantsCubit, ClassParticipantsState>(
                    builder: (context, state) {
                      if (state is ClassParticipantsLoaded) {
                        if (state.participants.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: state.participants.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = state.participants[index];
                            final String fullName =
                                "${user.firstName} ${user.lastName}";

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                // 1. Zastąpiono nowym widżetem Awatara
                                leading: ModernUserAvatar(
                                  firstName: user.firstName,
                                  lastName: user.lastName,
                                  photoUrl: user.photoUrl,
                                ),
                                // 2. IMIĘ I NAZWISKO
                                title: Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                // 3. TELEFON
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.phoneNumber,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                                // 4. IKONA INFO
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed: () =>
                                      _showUserDetails(context, user),
                                ),
                                onTap: () => _showUserDetails(context, user),
                              ),
                            );
                          },
                        );
                      }

                      // Loader pasujący do reszty apki
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      );
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
          Icon(
            Icons.person_off_outlined,
            size: 60,
            color: Colors.deepPurple.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "Brak zapisanych uczestników",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mały, szary uchwyt na górze bottom sheet'a (popularny UX)
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Nagłówek wizytówki
                Row(
                  children: [
                    ModernUserAvatar(
                      firstName: user.firstName,
                      lastName: user.lastName,
                      photoUrl: user.photoUrl,
                      radius: 32,
                      fontSize: 22,
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
                        const SizedBox(height: 4),
                        Text(
                          user.userRole.displayName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Szczegółowe dane (używają nowego uniwersalnego widżetu)
                ModernInfoRow(
                  icon: Icons.email_outlined,
                  label: "E-mail",
                  value: user.email,
                ),
                const SizedBox(height: 16),
                ModernInfoRow(
                  icon: Icons.phone_outlined,
                  label: "Telefon",
                  value: user.phoneNumber,
                ),
                const SizedBox(height: 16),
                ModernInfoRow(
                  icon: Icons.person_outline,
                  label: "Płeć",
                  value: user.sexRole.displayName,
                ),

                const SizedBox(height: 32),

                // Przycisk zamknięcia
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepPurple, // Główny fioletowy kolor
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Zamknij",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
