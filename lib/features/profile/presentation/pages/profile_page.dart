import 'package:agym/core/enums/user_role.dart';
import 'package:agym/core/utils/sex_role_extensions.dart';
import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/core/widget/login_out_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
          LoginOutButton(),
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
                    label: Text(switch (user.userRole) {
                      UserRole.manager => "MENADŻER",
                      UserRole.trainer => "TRENER",
                      UserRole.cashier => "KASJER",
                      _ => "KLIENT",
                    }, style: const TextStyle(color: Colors.white)),
                    backgroundColor: user.userRole.color,
                  ),

                  if (user.userRole == UserRole.manager)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text("Panel Menadżera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Przejście do panelu admina
                        context.push('/admin');
                      },
                    ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 4. Lista szczegółów (Email, Telefon, Płeć)
                  _buildProfileItem(Icons.email, "E-mail", user.email),
                  _buildProfileItem(Icons.phone, "Telefon", user.phoneNumber),
                  _buildProfileItem(Icons.wc, "Płeć", user.sexRole.displayName),
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
}
