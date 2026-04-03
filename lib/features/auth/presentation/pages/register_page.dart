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

  SexRole _selectedSex = SexRole.man;
  bool _isPasswordObscured = true;

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812); // Bardzo ciemna zieleń
  final Color _surfaceColor = const Color(0xFF1E2B21); // Wypełnienie pól
  final Color _primaryColor = const Color(0xFF00E676); // Neonowy zielony
  final Color _borderColor = const Color(0xFF2A3D2D); // Subtelna ramka
  final Color _textHintColor = const Color(0xFF8B9D90); // Szaro-zielony tekst

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
      final newUser = User(
        id: '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        userRole: UserRole.client,
        sexRole: _selectedSex,
        photoUrl: null,
      );

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Utwórz konto",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
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
          if (state is Authenticated) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }

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
                  // Krok (Step Indicator)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tytuł
                  const Text(
                    "Zaczynajmy",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Podtytuł
                  Text(
                    "Wprowadź swoje dane poniżej, aby dołączyć do naszej społeczności fitness.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Imię
                  _buildInputField(
                    label: "Imię",
                    hint: "Jan",
                    controller: _firstNameController,
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Wpisz swoje imię" : null,
                  ),
                  const SizedBox(height: 20),

                  // Nazwisko
                  _buildInputField(
                    label: "Nazwisko",
                    hint: "Kowalski",
                    controller: _lastNameController,
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v!.isEmpty ? "Wpisz swoje nazwisko" : null,
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _buildInputField(
                    label: "Adres e-mail",
                    hint: "jan@kowalski.pl",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.contains("@") ? null : "Nieprawidłowy adres e-mail",
                  ),
                  const SizedBox(height: 20),

                  // Telefon
                  _buildInputField(
                    label: "Numer telefonu",
                    hint: "+48 000 000 000",
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v!.isEmpty ? "Wpisz numer telefonu" : null,
                  ),
                  const SizedBox(height: 20),

                  // Płeć (Dropdown wykorzystujący wartość z enuma)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Płeć",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<SexRole>(
                        initialValue: _selectedSex,
                        dropdownColor: _surfaceColor,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF8B9D90),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: _inputDecoration(hint: "Wybierz płeć"),
                        items: SexRole.values.map((sex) {
                          // Pobieramy bezpośrednio przypisanego stringa (np. "Man", "Woman", "Other")
                          return DropdownMenuItem(
                            value: sex,
                            child: Text(sex.value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSex = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hasło
                  _buildInputField(
                    label: "Hasło",
                    hint: "••••••••",
                    controller: _passwordController,
                    icon: Icons.visibility_off_outlined,
                    isPassword: true,
                    validator: (v) => v!.length < 6
                        ? "Musi składać się z co najmniej 6 znaków"
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hasło musi zawierać minimum 6 znaków.",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 40),

                  // Przycisk
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor:
                            Colors.black, // Ciemny tekst na jasnym tle
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: _primaryColor.withValues(alpha: 0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Kontynuuj",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Przejście do logowania
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: "Masz już konto? ",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Zaloguj się",
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDŻET POMOCNICZY: POLE TEKSTOWE ---
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _isPasswordObscured : false,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: _primaryColor,
          decoration: _inputDecoration(hint: hint).copyWith(
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
                : Icon(icon, color: _textHintColor, size: 22),
          ),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _textHintColor, fontSize: 15),
      filled: true,
      fillColor: _surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}
