import 'package:agym/core/enums/sex_role.dart';
import 'package:agym/core/enums/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Twój Profil"),
        centerTitle: true,
        actions: [
          // Przycisk Wylogowania
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () {
              // To wywoła zmianę stanu na Unauthenticated
              // AuthGate w main.dart to wykryje i przeniesie nas na /login
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // Sprawdzamy, czy mamy dane użytkownika
          if (state is Authenticated) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 1. Awatar (Placeholder lub inicjały)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      user.firstName[0]
                          .toUpperCase(), // Pierwsza litera imienia
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Imię i Nazwisko
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 3. Rola (np. Klient / Trener)
                  Chip(
                    label: Text(
                      user.userRole == UserRole.trainer ? "Trener" : "Klient",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: user.userRole == UserRole.trainer
                        ? Colors.orange
                        : Colors.green,
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 4. Lista szczegółów (Email, Telefon, Płeć)
                  _buildProfileItem(Icons.email, "E-mail", user.email),
                  _buildProfileItem(Icons.phone, "Telefon", user.phoneNumber),
                  _buildProfileItem(
                    Icons.wc,
                    "Płeć",
                    _translateSex(user.sexRole),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Pomocnicza funkcja do budowania wierszy z danymi
  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  // Tłumacz płci z Enuma na Polski
  String _translateSex(SexRole sex) {
    switch (sex) {
      case SexRole.man:
        return "Mężczyzna";
      case SexRole.woman:
        return "Kobieta";
      default:
        return "Inna";
    }
  }
}
