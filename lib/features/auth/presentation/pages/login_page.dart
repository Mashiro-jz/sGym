import 'package:agym/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // Brak standardowego AppBar, żeby zachować czysty wygląd jak na mockupie
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centrujemy elementy
                  children: [
                    // --- LOGO (Świecący kwadrat z hantlem) ---
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: Colors.black, // Czarna ikona na neonowym tle
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- TYTUŁY ---
                    const Text(
                      "Witaj ponownie!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Wróćmy do Twoich celów fitness.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- POLA TEKSTOWE ---
                    _buildInputField(
                      hint: "Adres e-mail",
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Podaj e-mail';
                        if (!value.contains('@'))
                          return 'Błędny format e-maila';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      hint: "Hasło",
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.length < 6)
                          return 'Hasło musi mieć min. 6 znaków';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- ZAPOMNIAŁEŚ HASŁA ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Nawigacja do resetu hasła
                        },
                        child: Text(
                          "Zapomniałeś hasła?",
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- PRZYCISK LOGOWANIA ---
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: _primaryColor,
                            ),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: _primaryColor.withValues(alpha: 0.4),
                            ),
                            child: const Text(
                              "Zaloguj się",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // --- PRZERYWNIK "Lub kontynuuj przez" ---
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: _borderColor, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Lub kontynuuj przez",
                            style: TextStyle(
                              color: _textHintColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: _borderColor, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- REJESTRACJA ---
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Nie masz konta? ",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Zarejestruj się",
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDŻET POMOCNICZY: POLE TEKSTOWE Z IKONĄ W ŚRODKU ---
  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isPasswordObscured : false,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: _primaryColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textHintColor, fontSize: 15),
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        prefixIcon: Icon(prefixIcon, color: _textHintColor, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textHintColor,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              )
            : null,
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
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  // --- WIDŻET POMOCNICZY: PRZYCISK SOCIAL MEDIA ---
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent, // Tło przezroczyste na mockupie
          borderRadius: BorderRadius.circular(30), // Mocne zaokrąglenie
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
