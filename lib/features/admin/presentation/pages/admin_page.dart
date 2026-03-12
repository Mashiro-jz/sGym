import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/injection_container.dart' as di;
import '../../../../core/enums/user_role.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AdminCubit>()..fetchUsers(),
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatefulWidget {
  const _AdminView();

  @override
  State<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<_AdminView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is AdminUsersLoaded) {
            // 1. Logika filtrowania listy
            final allUsers = state.users;
            final filteredUsers = allUsers.where((user) {
              final query = _searchQuery.toLowerCase();
              return user.lastName.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.firstName.toLowerCase().contains(query);
            }).toList();

            // 2. Logika Statystyk
            final totalUsers = allUsers.length;
            final trainersCount = allUsers
                .where((u) => u.userRole == UserRole.trainer)
                .length;
            final cashiersCount = allUsers
                .where((u) => u.userRole == UserRole.cashier)
                .length;
            final clientsCount = allUsers
                .where((u) => u.userRole == UserRole.client)
                .length;

            return Column(
              children: [
                // SEKCJA 1: Statystyki (Karty na górze)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Usunąłem "Wszyscy", żeby zmieścić 4 kafelki ról,
                      // albo można zostawić "Wszyscy" i użyć mniejszego paddingu/fontu.
                      // Tutaj zostawiam "Wszyscy" i dodaję Kasjerów.
                      _buildStatCard(
                        "Wszyscy",
                        totalUsers.toString(),
                        Colors.blueGrey,
                      ),
                      const SizedBox(width: 5),
                      _buildStatCard(
                        "Trenerzy",
                        trainersCount.toString(),
                        Colors.orange,
                      ),
                      const SizedBox(width: 5),
                      _buildStatCard(
                        "Kasjerzy",
                        cashiersCount.toString(),
                        Colors.green,
                      ),
                      const SizedBox(width: 5),
                      _buildStatCard(
                        "Klienci",
                        clientsCount.toString(),
                        Colors.blue,
                      ),
                    ],
                  ),
                ),

                // SEKCJA 2: Wyszukiwarka
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Szukaj użytkownika...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // SEKCJA 3: Lista
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserTile(context, user);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text("Brak danych"));
        },
      ),
    );
  }

  // Kafelki Statystyk
  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), // Delikatne tło
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20, // Trochę mniejszy font, żeby się zmieściło
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: color), // Mniejszy opis
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Kafelek Użytkownika na liście
  Widget _buildUserTile(BuildContext context, User user) {
    // Pomocnicza funkcja do wyświetlania inicjałów (żeby nie kopiować kodu)
    Widget buildInitials() {
      return Center(
        child: Text(
          user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?",
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.userRole.color,
          child: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
              ? Image.network(
                  user.photoUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Błąd ładowania obrazka -> pokaż inicjały
                    return buildInitials();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(strokeWidth: 2);
                  },
                )
              : buildInitials(),
        ),
        title: Text("${user.firstName} ${user.lastName}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 12)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.userRole.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.userRole.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: user.userRole.color,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<UserRole>(
          icon: const Icon(Icons.more_vert),
          onSelected: (UserRole newRole) {
            context.read<AdminCubit>().updateUserRoleAction(
              uid: user.id,
              newRole: newRole,
            );
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<UserRole>>[
            const PopupMenuItem<UserRole>(
              value: UserRole.client,
              child: Text('Zmień na: Klient'),
            ),
            const PopupMenuItem<UserRole>(
              value: UserRole.trainer,
              child: Text('Zmień na: Trener'),
            ),
            const PopupMenuItem<UserRole>(
              value: UserRole.cashier,
              child: Text('Zmień na: Kasjer'),
            ),
          ],
        ),
      ),
    );
  }
}
