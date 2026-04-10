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

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  void _showDeleteConfirmationDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surfaceColor, // Ciemne tło dialogu
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _borderColor),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              const Text(
                "Usuń konto",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tej operacji nie można cofnąć. Wszystkie Twoje dane zostaną trwale usunięte.",
                style: TextStyle(color: _textHintColor),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Aby potwierdzić, wpisz swoje hasło:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.redAccent,
                decoration: _buildInputDecoration("Hasło", Icons.lock_outline)
                    .copyWith(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                      ),
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Anuluj", style: TextStyle(color: _textHintColor)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<UserCubit>().deleteUserAccount(
                  passwordController.text,
                );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                foregroundColor: Colors.redAccent,
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
      labelStyle: TextStyle(color: _textHintColor),
      prefixIcon: Icon(
        icon,
        color: isReadOnly
            ? _textHintColor.withValues(alpha: 0.5)
            : _primaryColor,
      ),
      filled: true,
      fillColor: isReadOnly
          ? Colors.black.withValues(alpha: 0.2)
          : _surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserDataUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Profil zaktualizowany pomyślnie!",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthCubit>().checkAuthStatus();
          context.pop();
        } else if (state is UserAccountDeleted) {
          context.pop();
          context.read<AuthCubit>().logout();
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is UserLoading;

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            title: const Text(
              "Edytuj Profil",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: _bgColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: _primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: _primaryColor,
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
                                  color: _primaryColor, // Neonowy zielony
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        _bgColor, // Tło aplikacji jako odstęp
                                    width: 4,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors
                                        .black, // Czarna ikona dla kontrastu
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "Zmiana zdjęcia - wkrótce!",
                                        ),
                                        backgroundColor: _surfaceColor,
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
                            fontSize: 14,
                            color: Colors.white,
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
                          style: TextStyle(color: _textHintColor),
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
                          style: TextStyle(color: _textHintColor),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          "Dane osobowe",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _firstNameController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: _primaryColor,
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
                          style: const TextStyle(color: Colors.white),
                          cursorColor: _primaryColor,
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
                          style: const TextStyle(color: Colors.white),
                          cursorColor: _primaryColor,
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
                          dropdownColor: _surfaceColor,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: _buildInputDecoration(
                            "Płeć",
                            Icons.wc_outlined,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: _primaryColor,
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
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.black,
                              elevation: 4,
                              shadowColor: _primaryColor.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Zapisz zmiany",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        Divider(thickness: 1, color: _borderColor),
                        const SizedBox(height: 20),

                        // --- SEKCJA USUWANIA KONTA ---
                        const Text(
                          "Strefa niebezpieczna",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 14,
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
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(
                                color: Colors.redAccent,
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
              return Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            },
          ),
        );
      },
    );
  }
}
