import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ScheduleDetailsPage extends StatelessWidget {
  final GymClass gymClass;
  final String name; // Imię trenera

  const ScheduleDetailsPage({
    super.key,
    required this.gymClass,
    required this.name,
  });

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    // Sprawdzamy czy zajęcia już się rozpoczęły (lub odbyły w przeszłości)
    final hasStarted = DateTime.now().isAfter(gymClass.startTime);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          "Szczegóły",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 32),
            const Text(
              "Prowadzący",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrainerInfo(),
            const SizedBox(height: 32),
            const Text(
              "O zajęciach",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildClassDescription(),
            if (!hasStarted) const SizedBox(height: 100),
          ],
        ),
      ),
      // Dolny panel z przyciskiem do zapisów
      bottomSheet: hasStarted
          ? null
          : Container(
              color: _bgColor,
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      if (authState is! Authenticated) {
                        return const SizedBox.shrink();
                      }
                      final currentUserId = authState.user.id;

                      return BlocBuilder<ScheduleCubit, ScheduleState>(
                        builder: (context, scheduleState) {
                          GymClass currentClass = gymClass;
                          if (scheduleState is ScheduleLoaded) {
                            try {
                              currentClass = scheduleState.classes.firstWhere(
                                (c) => c.id == gymClass.id,
                              );
                            } catch (e) {
                              // Ignorujemy
                            }
                          }

                          final isEnrolled = currentClass.registeredUserIds
                              .contains(currentUserId);
                          final isLoading = scheduleState is ScheduleLoading;

                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();

                                    try {
                                      if (isEnrolled) {
                                        await context
                                            .read<ScheduleCubit>()
                                            .signOutFromClassActivity(
                                              currentClass,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            _buildModernSnackBar(
                                              "Wypisano z zajęć.",
                                              isSuccess: true,
                                            ),
                                          );
                                        }
                                      } else {
                                        await context
                                            .read<ScheduleCubit>()
                                            .signUpForClassActivity(
                                              currentClass,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            _buildModernSnackBar(
                                              "Zapisano na zajęcia.",
                                              isSuccess: true,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          _buildModernSnackBar(
                                            "Wystąpił błąd.",
                                            isSuccess: false,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnrolled
                                  ? Colors.transparent
                                  : _primaryColor,
                              foregroundColor: isEnrolled
                                  ? Colors.redAccent
                                  : Colors.black,
                              side: isEnrolled
                                  ? const BorderSide(
                                      color: Colors.redAccent,
                                      width: 1.5,
                                    )
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: isEnrolled || isLoading ? 0 : 8,
                              shadowColor: _primaryColor.withValues(alpha: 0.4),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEnrolled
                                        ? "Wypisz się z zajęć"
                                        : "Zapisz się na zajęcia",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  // --- WIDŻETY POMOCNICZE ---

  Widget _buildHeroCard() {
    final timeString =
        "${gymClass.startTime.hour}:${gymClass.startTime.minute.toString().padLeft(2, '0')}";
    final dateString =
        "${gymClass.startTime.day.toString().padLeft(2, '0')}.${gymClass.startTime.month.toString().padLeft(2, '0')}.${gymClass.startTime.year}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              gymClass.category.toUpperCase(),
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            gymClass.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildHeroIcon(Icons.calendar_today_outlined, dateString),
              const SizedBox(width: 20),
              _buildHeroIcon(Icons.access_time, timeString),
              const SizedBox(width: 20),
              _buildHeroIcon(
                Icons.timer_outlined,
                "${gymClass.durationMinutes} min",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: _bgColor,
            child: Icon(Icons.person, color: _primaryColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Trener Personalny",
                  style: TextStyle(color: _textHintColor, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: _textHintColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildClassDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gymClass.description,
            style: TextStyle(color: Colors.grey.shade300, height: 1.5),
          ),
          const SizedBox(height: 20),
          Divider(color: _borderColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Poziom", gymClass.classLevel.displayName),
              _buildInfoColumn("Spalanie", "~450 kcal"),
              _buildInfoColumn("Sala", "Główna"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _textHintColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- NOWY, NOWOCZESNY SNACKBAR (DARK THEME) ---
  SnackBar _buildModernSnackBar(String message, {required bool isSuccess}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade600 : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 90, left: 24, right: 24),
      duration: const Duration(milliseconds: 1500),
      elevation: 8,
    );
  }
}
