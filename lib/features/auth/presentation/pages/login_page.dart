import 'package:agym/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
// Upewnij się, że ten import wskazuje na Twój plik RegisterPage (stworzymy go za chwilę)
// Na razie możesz to zakomentować lub stworzyć pusty plik, żeby nie było błędu.
// import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Kontrolery do pobierania tekstu z pól
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Klucz formularza do walidacji (np. czy email zawiera @)
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      // Wywołujemy funkcję logowania z Cubita
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logowanie sGym")),
      // BlocListener nasłuchuje zmian stanu, żeby pokazać np. komunikat błędu
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Witaj ponownie!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Pole Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Podaj e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'Błędny format e-maila';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Pole Hasło
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Hasło",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true, // Ukrywanie znaków
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Hasło musi mieć min. 6 znaków';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Przycisk Logowania
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onLoginPressed,
                        child: const Text("Zaloguj się"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Przycisk przejścia do Rejestracji
                TextButton(
                  onPressed: () {
                    // Tutaj dodamy nawigację do rejestracji w następnym kroku
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text("Nie masz konta? Zarejestruj się"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
