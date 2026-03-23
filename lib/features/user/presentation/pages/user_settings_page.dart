import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/injection_container.dart' as di;
import '../../../../core/enums/sex_role.dart';
import '../../../../core/utils/sex_role_extensions.dart';
import '../../../../core/widget/modern_user_avatar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UserCubit>(),
      child: const _ProfileSettingsView(),
    );
  }
}

class _ProfileSettingsView extends StatefulWidget {
  const _ProfileSettingsView();

  @override
  State<_ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<_ProfileSettingsView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  SexRole? _selectedSex;

  void _showDeleteConfirmationDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
              const SizedBox(width: 8),
              const Text("Usuń konto"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tej operacji nie można cofnąć. Wszystkie Twoje dane zostaną trwale usunięte.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              const Text(
                "Aby potwierdzić, wpisz swoje hasło:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _buildInputDecoration("Hasło", Icons.lock_outline),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Anuluj", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<UserCubit>().deleteUserAccount(
                  passwordController.text,
                );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "USUŃ KONTO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;

    if (authState is Authenticated) {
      final user = authState.user;
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _phoneController = TextEditingController(text: user.phoneNumber);
      _emailController = TextEditingController(text: user.email);
      _selectedSex = user.sexRole;
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _selectedSex = SexRole.other;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;

      if (authState is Authenticated) {
        final currentUser = authState.user;

        context.read<UserCubit>().submitUserDataUpdate(
          uid: currentUser.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text,
          photoUrl: currentUser.photoUrl,
          sexRole: _selectedSex!,
        );
      }
    }
  }

  // --- POMOCNICZY WIDŻET DEKORACJI PÓL TEXTOWYCH ---
  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    bool isReadOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(
        icon,
        color: isReadOnly ? Colors.grey : Colors.deepPurple,
      ),
      filled: true,
      fillColor: isReadOnly ? Colors.grey.shade200 : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserDataUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil zaktualizowany pomyślnie!"),
              backgroundColor: Colors.green,
            ),
          );
          context.read<AuthCubit>().checkAuthStatus();
          context.pop();
        } else if (state is UserAccountDeleted) {
          context.pop();
          context.read<AuthCubit>().logout();
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is UserLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              "Edytuj Profil",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                  onPressed: () => _saveProfile(context),
                  tooltip: "Zapisz",
                ),
            ],
          ),
          body: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                final user = authState.user;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ZDJĘCIE PROFILOWE ---
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ModernUserAvatar(
                                firstName: user.firstName,
                                lastName: user.lastName,
                                photoUrl: user.photoUrl,
                                radius: 56,
                                fontSize: 36,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Zmiana zdjęcia - wkrótce!",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        const Text(
                          "Dane konta (tylko do odczytu)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          initialValue: user.id,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            "User ID",
                            Icons.fingerprint,
                            isReadOnly: true,
                          ),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            "E-mail",
                            Icons.email_outlined,
                            isReadOnly: true,
                          ),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          "Dane osobowe",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _firstNameController,
                          decoration: _buildInputDecoration(
                            "Imię",
                            Icons.person_outline,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "To pole jest wymagane"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _lastNameController,
                          decoration: _buildInputDecoration(
                            "Nazwisko",
                            Icons.person_outline,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "To pole jest wymagane"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          decoration: _buildInputDecoration(
                            "Telefon",
                            Icons.phone_outlined,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty
                              ? "To pole jest wymagane"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<SexRole>(
                          initialValue: _selectedSex,
                          decoration: _buildInputDecoration(
                            "Płeć",
                            Icons.wc_outlined,
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.deepPurple,
                          ),
                          items: SexRole.values.map((sex) {
                            return DropdownMenuItem(
                              value: sex,
                              child: Text(sex.displayName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSex = val);
                          },
                        ),
                        const SizedBox(height: 40),

                        // Przycisk Zapisz
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _saveProfile(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Zapisz zmiany",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        Divider(thickness: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 20),

                        // --- SEKCJA USUWANIA KONTA ---
                        const Text(
                          "Strefa niebezpieczna",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _showDeleteConfirmationDialog(context),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text(
                              "Usuń konto na zawsze",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            },
          ),
        );
      },
    );
  }
}
