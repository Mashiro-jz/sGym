import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Importy core i konfiguracji
import '../../../../core/config/injection_container.dart' as di;
import '../../../../core/enums/sex_role.dart';
import '../../../../core/utils/sex_role_extensions.dart'; // Upewnij się, że masz to rozszerzenie

// Importy Auth (do odczytu aktualnego usera i odświeżania po zapisie)
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

// Importy User (do zapisu zmian)
import '../cubit/user_cubit.dart';
import '../cubit/user_state.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Wstrzykujemy UserCubit (odpowiedzialny za zapis)
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

  // Kontrolery formularza
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  // Zmienna dla wybranej płci
  SexRole? _selectedSex;

  @override
  void initState() {
    super.initState();
    // 2. Pobieramy aktualne dane zalogowanego użytkownika z AuthCubit
    final authState = context.read<AuthCubit>().state;

    if (authState is Authenticated) {
      final user = authState.user;
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _phoneController = TextEditingController(text: user.phoneNumber);
      _emailController = TextEditingController(text: user.email);
      _selectedSex = user.sexRole;
    } else {
      // Zabezpieczenie (gdyby user nie był zalogowany - mało prawdopodobne tutaj)
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

  // Funkcja zapisu danych
  void _saveProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;

      if (authState is Authenticated) {
        final currentUser = authState.user;

        // Wywołujemy UserCubit, aby wysłać dane do Firebase
        context.read<UserCubit>().submitUserDataUpdate(
          uid: currentUser.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController
              .text, // Email (read-only) przesyłamy dla spójności
          photoUrl: currentUser.photoUrl, // Na razie zostawiamy stare zdjęcie
          sexRole: _selectedSex!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Nasłuchujemy zmian w UserCubit (Sukces/Błąd/Ładowanie)
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserDataUpdateSuccess) {
          // A. Sukces -> Pokaż info
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil zaktualizowany pomyślnie!"),
              backgroundColor: Colors.green,
            ),
          );

          // B. Odśwież dane w głównej sesji (AuthCubit), żeby zmiany były widoczne w całej aplikacji
          context.read<AuthCubit>().checkAuthStatus();

          // C. Wróć do poprzedniego ekranu
          context.pop();
        } else if (state is UserError) {
          // D. Błąd -> Pokaż komunikat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Blokujemy ekran podczas ładowania
        final isLoading = state is UserLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Edytuj Profil"),
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.check),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // --- SEKCJA ZDJĘCIA (Wizualna) ---
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.blueGrey.shade100,
                                backgroundImage:
                                    (user.photoUrl != null &&
                                        user.photoUrl!.isNotEmpty)
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child:
                                    (user.photoUrl == null ||
                                        user.photoUrl!.isEmpty)
                                    ? Text(
                                        user.firstName.isNotEmpty
                                            ? user.firstName[0].toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          fontSize: 40,
                                          color: Colors.blueGrey,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 20,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Zmiana zdjęcia - wkrótce!",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- POLA FORMULARZA ---

                        // UID (Tylko do odczytu)
                        TextFormField(
                          initialValue: user.id,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "User ID",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white10,
                            prefixIcon: Icon(Icons.fingerprint),
                          ),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),

                        // Email (Tylko do odczytu)
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "E-mail",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white10,
                            prefixIcon: Icon(Icons.email),
                          ),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),

                        // Imię
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: "Imię",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "To pole jest wymagane"
                              : null,
                        ),
                        const SizedBox(height: 15),

                        // Nazwisko
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: "Nazwisko",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "To pole jest wymagane"
                              : null,
                        ),
                        const SizedBox(height: 15),

                        // Telefon
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: "Telefon",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty
                              ? "To pole jest wymagane"
                              : null,
                        ),
                        const SizedBox(height: 15),

                        // Płeć (Dropdown)
                        DropdownButtonFormField<SexRole>(
                          initialValue: _selectedSex,
                          decoration: const InputDecoration(
                            labelText: "Płeć",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.wc),
                          ),
                          items: SexRole.values.map((sex) {
                            return DropdownMenuItem(
                              value: sex,
                              // Użycie extension SexRoleX do wyświetlania nazwy
                              child: Text(sex.displayName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSex = val;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 30),

                        // Przycisk Zapisz (Duży na dole)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _saveProfile(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("Zapisz zmiany"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
}
