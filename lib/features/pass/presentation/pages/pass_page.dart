import 'dart:async';
import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

// TODO: PRZETESTUJ MNIE I PRZECZYTAJ O MNIE

class PassPage extends StatefulWidget {
  const PassPage({super.key});

  @override
  State<PassPage> createState() => _PassPageState();
}

class _PassPageState extends State<PassPage>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  double _progress = 1.0;
  late String _currentQrData;
  final bool __hasActivePass =
      true; // Ta zmienna aktualnie jest na sztywno do przetestowania
  final int _refreshIntervalSeconds = 30; // Czas co ile tworzymy nowy kod QR

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  void initState() {
    super.initState();
    _generateQrData();
    _startTimer();
  }

  void _generateQrData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final userId = authState.user.id;
      final timeWindow =
          DateTime.now().millisecondsSinceEpoch ~/
          (_refreshIntervalSeconds * 1000);

      setState(() {
        _currentQrData = "$userId:$timeWindow";
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      final currentMillisInWindow =
          now.millisecondsSinceEpoch % (_refreshIntervalSeconds * 1000);

      setState(() {
        _progress =
            1.0 - (currentMillisInWindow / (_refreshIntervalSeconds * 1000));
      });

      if (_progress >= 0.99) {
        _generateQrData();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: Text(
            "Zaloguj się, aby zobaczyć karnet",
            style: TextStyle(color: _textHintColor),
          ),
        ),
      );
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          "Twój Karnet",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wirtualna karta lojalnościowa / VIP Pass
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _surfaceColor, // Ciemnozielone tło karty
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: _borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    // Subtelny neonowy blask z tyłu
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.05),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Nagłówek Karty
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "sGym Pass",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Icon(
                          Icons.contactless_outlined,
                          color: _primaryColor, // Neonowa ikona NFC
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Białe tło pod kod QR (WYMAGANE DLA SKANERÓW)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        // Delikatny wewnętrzny cień dla kontrastu
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (__hasActivePass) ...[
                            QrImageView(
                              data: _currentQrData,
                              version: QrVersions.auto,
                              size: 200.0,
                              // Kod generowany jest na czarno, na białym tle - idealnie!
                            ),
                            const SizedBox(height: 20),

                            // Pasek postępu odświeżania
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _primaryColor, // Neonowy pasek odświeżania!
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Kod odświeża się automatycznie",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ] else ...[
                            // Stan gdy karnet wygasł
                            Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.block,
                                    size: 64,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Brak aktywnego karnetu",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Informacje o użytkowniku
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _bgColor,
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              color: _primaryColor, // Neonowa litera
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${user.firstName} ${user.lastName}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "Status: ",
                                  style: TextStyle(
                                    color: _textHintColor,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  __hasActivePass ? 'Aktywny' : 'Nieaktywny',
                                  style: TextStyle(
                                    color: __hasActivePass
                                        ? _primaryColor
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Ostrzeżenie
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 18, color: _textHintColor),
                  const SizedBox(width: 8),
                  Text(
                    "Zrzuty ekranu nie będą honorowane na bramce.",
                    style: TextStyle(color: _textHintColor, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
