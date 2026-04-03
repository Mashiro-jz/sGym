import 'package:agym/core/utils/user_role_extensions.dart';
import 'package:agym/core/widget/modern_user_avatar.dart';
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Admin Panel",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      _buildStatCard(
                        "Wszyscy",
                        totalUsers.toString(),
                        Colors.blueGrey,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        "Trenerzy",
                        trainersCount.toString(),
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        "Kasjerzy",
                        cashiersCount.toString(),
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
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
                    decoration: InputDecoration(
                      hintText: "Szukaj użytkownika...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // SEKCJA 3: Lista
                Expanded(
                  child: filteredUsers.isEmpty
                      ? _buildEmptySearchState()
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
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

  // --- WIDŻETY POMOCNICZE ---

  Widget _buildStatCard(String title, String count, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade100),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: color.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Nie znaleziono użytkownika",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- KAFELEK UŻYTKOWNIKA ---

  Widget _buildUserTile(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ModernUserAvatar(
          firstName: user.firstName,
          lastName: user.lastName,
          photoUrl: user.photoUrl,
        ),
        title: Text(
          "${user.firstName} ${user.lastName}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              user.email,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: user.userRole.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.userRole.displayName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
          onPressed: () => _showUserActionsBottomSheet(context, user),
        ),
      ),
    );
  }

  // --- SERCE NOWEGO PANELU CRM (BOTTOM SHEET) ---

  void _showUserActionsBottomSheet(BuildContext context, User user) {
    final adminCubit = context.read<AdminCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Zarządzaj: ${user.firstName} ${user.lastName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // AKCJA 1: Nadaj Karnet
              _buildBottomSheetAction(
                icon: Icons.credit_card,
                color: Colors.green,
                title: "Aktywuj karnet na 30 dni",
                subtitle: "Oznacz jako opłacony gotówką",
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Prawdziwy strzał do bazy aktualizujący datę ważności karnetu
                  _showSuccessSnackBar(
                    context,
                    "Karnet aktywowany dla ${user.firstName}!",
                  );
                },
              ),
              Divider(color: Colors.grey.shade200, height: 24),

              // AKCJA 2: Zmiana Roli
              _buildBottomSheetAction(
                icon: Icons.manage_accounts_outlined,
                color: Colors.blue,
                title: "Zmień uprawnienia",
                subtitle: "Obecna rola: ${user.userRole.displayName}",
                onTap: () {
                  Navigator.pop(ctx);
                  _showRoleChangeDialog(context, user, adminCubit);
                },
              ),
              Divider(color: Colors.grey.shade200, height: 24),

              // AKCJA 3: Zablokuj
              _buildBottomSheetAction(
                icon: Icons.block,
                color: Colors.red,
                title: "Zablokuj użytkownika",
                subtitle: "Zawiesza dostęp do aplikacji",
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Dodać pole `isBlocked` w bazie
                  _showSuccessSnackBar(
                    context,
                    "Zablokowano konto ${user.firstName}.",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetAction({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // --- ZAKTUALIZOWANE OKNO ZMIANY ROLI DLA ADMINA (FLUTTER 3.32+) ---

  void _showRoleChangeDialog(
    BuildContext context,
    User user,
    AdminCubit adminCubit,
  ) {
    UserRole selectedRole = user.userRole;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Wybierz nową rolę",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Używamy nowego RadioGroup jako rodzica dla RadioListTile
            content: RadioGroup<UserRole>(
              groupValue: selectedRole,
              onChanged: (UserRole? newValue) {
                if (newValue != null) {
                  setState(() => selectedRole = newValue);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoleRadio(UserRole.client),
                  _buildRoleRadio(UserRole.trainer),
                  _buildRoleRadio(UserRole.cashier),
                  // Menedżer został stąd całkowicie usunięty!
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Anuluj",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (selectedRole != user.userRole) {
                    adminCubit.updateUserRoleAction(
                      uid: user.id,
                      newRole: selectedRole,
                    );
                    _showSuccessSnackBar(
                      context,
                      "Zmieniono rolę na: ${selectedRole.displayName}",
                    );
                  }
                },
                child: const Text(
                  "Zapisz",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoleRadio(UserRole role) {
    // Usunięto przestarzałe właściwości groupValue oraz onChanged
    return RadioListTile<UserRole>(
      title: Text(
        role.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      value: role,
      activeColor: role.color,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
