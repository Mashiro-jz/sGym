import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:agym/features/schedule/presentation/cubit/trainer_cubit.dart';
import 'package:agym/features/schedule/presentation/cubit/trainer_state.dart';
import 'package:agym/features/schedule/presentation/pages/trainer/trainer_class_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/injection_container.dart' as di;

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    // 1. Zabezpieczenie: Jeśli użytkownik nie jest zalogowany
    if (authState is! Authenticated) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: _textHintColor),
              const SizedBox(height: 16),
              Text(
                "Brak dostępu do tego ekranu.",
                style: TextStyle(color: _textHintColor, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Główny widok dla zalogowanego trenera
    return BlocProvider(
      create: (context) =>
          di.sl<TrainerCubit>()..loadTrainerClasses(authState.user.id),
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          title: const Text(
            "Twój Grafik",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: _bgColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<TrainerCubit, TrainerState>(
          builder: (BuildContext context, TrainerState state) {
            if (state is TrainerLoading) {
              return Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            if (state is TrainerError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 56,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          elevation: 4,
                          shadowColor: _primaryColor.withValues(alpha: 0.4),
                        ),
                        onPressed: () {
                          context.read<TrainerCubit>().loadTrainerClasses(
                            authState.user.id,
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          "Spróbuj ponownie",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TrainerLoaded) {
              if (state.classes.isEmpty) {
                return _buildEmptyState(context, authState.user.id);
              }

              return RefreshIndicator(
                color: _primaryColor,
                backgroundColor: _surfaceColor,
                onRefresh: () async {
                  context.read<TrainerCubit>().loadTrainerClasses(
                    authState.user.id,
                  );
                },
                child: ListView.builder(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Wymusza możliwość scrollowania nawet przy krótkiej liście (dla Pull-to-refresh)
                  padding: const EdgeInsets.all(24.0),
                  itemCount: state.classes.length,
                  itemBuilder: (context, index) {
                    final gymClass = state.classes[index];
                    return _buildClassCard(gymClass, context);
                  },
                ),
              );
            }

            return Center(
              child: Text(
                "Nie można załadować danych",
                style: TextStyle(color: _textHintColor, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDŻETY POMOCNICZE (W STYLU DARK FITNESS) ---

  Widget _buildClassCard(dynamic gymClass, BuildContext context) {
    final date = gymClass.startTime;
    final String dayString =
        "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}";
    final String timeString =
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    final hasStarted = DateTime.now().isAfter(gymClass.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.3,
            ), // Mocniejszy, wyraźniejszy cień
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: _primaryColor.withValues(
            alpha: 0.1,
          ), // Neonowy feedback przy dotyku
          splashColor: _primaryColor.withValues(alpha: 0.15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    TrainerClassDetailsPage(gymClass: gymClass),
              ),
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kolumna z Czasem (Lewa strona)
                Container(
                  width: 90, // Troszkę szerszy dla lepszej proporcji z godziną
                  decoration: BoxDecoration(
                    color: hasStarted
                        ? Colors.black.withValues(
                            alpha: 0.15,
                          ) // Wyszarzone jeśli było
                        : Colors.black.withValues(
                            alpha: 0.3,
                          ), // Wklęsłe ciemne tło
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: hasStarted ? _textHintColor : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayString,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: hasStarted
                              ? Colors.grey.shade700
                              : _textHintColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Informacje o zajęciach (Środek)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20, // Większy padding góra/dół
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gymClass.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 14,
                              color: _textHintColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              gymClass.category,
                              style: TextStyle(
                                fontSize: 13,
                                color: _textHintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Ikona strzałki (Prawa strona)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _textHintColor.withValues(
                      alpha: 0.5,
                    ), // Bardziej subtelna strzałka
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 80,
            color: _textHintColor.withValues(
              alpha: 0.5,
            ), // Jasniejsza ikona żeby nie ginęła
          ),
          const SizedBox(height: 24),
          const Text(
            "Brak zaplanowanych zajęć",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () =>
                context.read<TrainerCubit>().loadTrainerClasses(userId),
            icon: Icon(Icons.refresh, color: _primaryColor),
            label: Text(
              "Odśwież grafik",
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: _primaryColor.withValues(
                alpha: 0.15,
              ), // Mocniejsze podświetlenie
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
