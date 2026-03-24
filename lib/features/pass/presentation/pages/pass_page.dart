import 'dart:async';
import 'package:agym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agym/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  final bool __hasActivePass = true;
  final int _refreshIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    _generateQrData(); // Pierwsze wygenerowanie przy starcie
    _startTimer();
  }

  void _generateQrData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final userId = authState.user.id;
      // Dzielimy aktualny czas przez 30 sekund. To "okienko", które zmienia się co pół minuty.
      final timeWindow =
          DateTime.now().millisecondsSinceEpoch ~/
          (_refreshIntervalSeconds * 1000);

      setState(() {
        // Nasz oszukany, ale skuteczny na MVP dynamiczny payload
        _currentQrData = "$userId:$timeWindow";
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      // Obliczamy ile milisekund minęło w obecnym 30-sekundowym okienku
      final currentMillisInWindow =
          now.millisecondsSinceEpoch % (_refreshIntervalSeconds * 1000);

      setState(() {
        // Pasek postępu od 1.0 w dół do 0.0
        _progress =
            1.0 - (currentMillisInWindow / (_refreshIntervalSeconds * 1000));
      });

      // Jeśli okienko się zresetowało (pasek doszedł do zera), generujemy nowy QR
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
      return const Scaffold(
        body: Center(child: Text("Zaloguj się, aby zobaczyć karnet")),
      );
    }

    final user = authState.user;
    // TODO: Tutaj w przyszłości sprawdzisz, czy user._hasActivePass == true

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Twój Karnet",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wirtualna karta lojalnościowa / Karnet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade700,
                      Colors.deepPurple.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "sGym Pass",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Icon(
                          Icons.contactless_outlined,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Białe tło pod kod QR
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          if (__hasActivePass) ...[
                            QrImageView(
                              data: _currentQrData,
                              version: QrVersions.auto,
                              size: 200.0,
                              // USUNIĘTE: backgroundColor: Colors.white - jest dziedziczone z Containera
                            ),
                            const SizedBox(height: 16),
                            // Pasek postępu odświeżania
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple.shade300,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Kod odświeża się automatycznie",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
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
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Brak aktywnego karnetu",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                            Text(
                              "Status: ${__hasActivePass ? 'Aktywny' : 'Nieaktywny'}",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Ostrzeżenie (dobry UX)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Zrzuty ekranu nie będą honorowane na bramce.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
