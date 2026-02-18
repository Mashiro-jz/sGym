import 'package:agym/features/schedule/domain/entities/gym_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import pakietu intl

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

    return Scaffold(
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
          // --- SEKCJA 1: NAGŁÓWEK ZAJĘĆ ---
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
                    // Ikona typu zajęć
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

                // Wiersz z datą i godziną
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
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
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

                // Opis
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

          // --- SEKCJA 2: LISTA UCZESTNIKÓW ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Uczestnicy",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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

          Expanded(
            child: widget.gymClass.registeredUserIds.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.gymClass.registeredUserIds.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final userId = widget.gymClass.registeredUserIds[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.shade100,
                          foregroundColor: Colors.blueAccent.shade700,
                          child: Text(
                            (index + 1).toString(),
                          ), // Numeracja porządkowa
                        ),
                        title: const Text(
                          "Użytkownik", // Tu docelowo wstawisz imię
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "ID: $userId",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            // Opcjonalnie: Pokaż profil użytkownika
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget wyświetlany, gdy brak uczestników
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
}
