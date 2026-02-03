import 'package:agym/core/enums/sex_role.dart';
import 'package:agym/core/enums/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Kontrolery pól tekstowych
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Zmienne do przechowywania wyboru z list rozwijanych (Enumy)
  // Domyślnie ustawiamy np. Mężczyznę (lub można dać null)
  SexRole _selectedSex = SexRole.man;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      // 1. Tworzymy obiekt User (bez ID, bo ID nada Firebase)
      // ID wpisujemy tymczasowo puste, zostanie nadpisane w Repozytorium
      final newUser = User(
        id: '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        userRole: UserRole
            .client, // Ustawione na sztywno jako klient, bo to menadzer bedzie zmieniał to w panelu admina
        sexRole: _selectedSex,
        photoUrl: null, // Na razie brak zdjęcia
      );

      // 2. Wywołujemy Cubit
      context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        user: newUser,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rejestracja sGym")),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Jeśli rejestracja się uda (Authenticated), AuthGate w main.dart
          // automatycznie przeniesie nas na Home, ale musimy zamknąć ten ekran
          if (state is Authenticated) {
            Navigator.of(context).pop(); // Zamykamy ekran rejestracji
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            // Ważne: pozwala przewijać ekran
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Załóż nowe konto",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Imię
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: "Imię",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Wpisz imię" : null,
                  ),
                  const SizedBox(height: 10),

                  // Nazwisko
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: "Nazwisko",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Wpisz nazwisko" : null,
                  ),
                  const SizedBox(height: 10),

                  // Telefon
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Telefon",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Wpisz numer" : null,
                  ),
                  const SizedBox(height: 10),

                  // DROPDOWN: Płeć
                  DropdownButtonFormField<SexRole>(
                    initialValue: _selectedSex,
                    decoration: const InputDecoration(
                      labelText: "Płeć",
                      border: OutlineInputBorder(),
                    ),
                    items: SexRole.values.map((sex) {
                      // Tutaj robimy precyzyjne tłumaczenie dla każdej opcji
                      String label = "";
                      switch (sex) {
                        case SexRole
                            .man: // Upewnij się, że w modelu masz .male lub .man
                          label = "Mężczyzna";
                          break;
                        case SexRole.woman: // lub .woman
                          label = "Kobieta";
                          break;
                        default:
                          label = "Inna"; // Dla SexRole.other
                      }

                      return DropdownMenuItem(value: sex, child: Text(label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSex = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.contains("@") ? null : "Błędny email",
                  ),
                  const SizedBox(height: 10),

                  // Hasło
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Hasło",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? "Minimum 6 znaków" : null,
                  ),
                  const SizedBox(height: 30),

                  // Przycisk
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Zarejestruj się"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
