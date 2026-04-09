import 'package:agym/core/config/injection_container.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/features/auth/domain/entities/user.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/class_participants_state.dart';
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
  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

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
        backgroundColor: _bgColor,
        appBar: AppBar(
          title: const Text(
            "Szczegóły Zajęć",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: _bgColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEKCJA 1: NAGŁÓWEK ZAJĘĆ ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor),
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
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(Icons.fitness_center, color: _primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: _textHintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: TextStyle(color: _textHintColor, fontSize: 14),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.access_time, size: 16, color: _textHintColor),
                      const SizedBox(width: 6),
                      Text(
                        timeText,
                        style: const TextStyle(
                          color: Colors.white,
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
                      fontSize: 14,
                      color: Colors.grey.shade400,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      "${widget.gymClass.registeredUserIds.length} osób",
                      style: TextStyle(
                        color: _primaryColor,
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
                                color: _surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _borderColor),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: ModernUserAvatar(
                                  firstName: user.firstName,
                                  lastName: user.lastName,
                                  photoUrl: user.photoUrl,
                                ),
                                title: Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 14,
                                      color: _textHintColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.phoneNumber,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _textHintColor,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: _primaryColor,
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

                      return Center(
                        child: CircularProgressIndicator(color: _primaryColor),
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
          Icon(Icons.person_off_outlined, size: 60, color: _textHintColor),
          const SizedBox(height: 16),
          Text(
            "Brak zapisanych uczestników",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- ZMODERNIZOWANY WIDOK SZCZEGÓŁÓW (BOTTOM SHEET) ---
  // --- ZMODERNIZOWANY WIDOK SZCZEGÓŁÓW (BOTTOM SHEET) ---
  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor, // Ciemne tło
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
                // Szary uchwyt
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _borderColor,
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
                            color: Colors.white, // Gwarancja czytelności
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.userRole.displayName,
                          style: TextStyle(color: _textHintColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Szczegółowe dane
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

                // Zmieniony, bardziej czytelny przycisk zamknięcia (Outline)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Przezroczyste tło
                      foregroundColor: _primaryColor, // Neonowy zielony napis
                      side: BorderSide(
                        color: _primaryColor,
                        width: 2,
                      ), // Neonowa zielona ramka
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Zamknij",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
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
