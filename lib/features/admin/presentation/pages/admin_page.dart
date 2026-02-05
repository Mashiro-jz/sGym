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
    // 1. Wstrzykujemy Cubit i od razu pobieramy listę
    return BlocProvider(
      create: (context) => di.sl<AdminCubit>()..fetchUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Panel Menadżera"),
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            // A. Ładowanie
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // B. Błąd
            if (state is AdminError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            // C. Sukces - Mamy listę!
            if (state is AdminUsersLoaded) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return _buildUserTile(context, user);
                },
              );
            }

            return const Center(child: Text("Brak danych"));
          },
        ),
      ),
    );
  }

  // Pomocnicza funkcja budująca kafelek użytkownika
  Widget _buildUserTile(BuildContext context, User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.userRole),
          child: Text(
            user.firstName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text("${user.firstName} ${user.lastName}"),
        subtitle: Text("${user.email}\nRola: ${_translateRole(user.userRole)}"),
        isThreeLine: true,
        trailing: PopupMenuButton<UserRole>(
          icon: const Icon(Icons.edit),
          onSelected: (UserRole newRole) {
            // Wywołujemy funkcję zmiany roli w Cubicie
            context.read<AdminCubit>().updateUserRoleAction(
              uid: user.id,
              newRole: newRole,
            );
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<UserRole>>[
            const PopupMenuItem<UserRole>(
              value: UserRole.client,
              child: Text('Ustaw jako: Klient'),
            ),
            const PopupMenuItem<UserRole>(
              value: UserRole.trainer,
              child: Text('Ustaw jako: Trener'),
            ),
            const PopupMenuItem<UserRole>(
              value: UserRole.cashier,
              child: Text('Ustaw jako: Kasjer'),
            ),
            const PopupMenuItem<UserRole>(
              value: UserRole.manager,
              child: Text('Ustaw jako: Menadżer'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return Colors.red;
      case UserRole.trainer:
        return Colors.orange;
      case UserRole.client:
        return Colors.blue;
      case UserRole.cashier:
        return Colors.green;
    }
  }

  String _translateRole(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return "Menadżer";
      case UserRole.trainer:
        return "Trener";
      case UserRole.client:
        return "Klient";
      case UserRole.cashier:
        return "Kasjer";
    }
  }
}
