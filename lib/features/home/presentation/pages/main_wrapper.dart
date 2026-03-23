import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatelessWidget {
  // To "child" to jest właśnie aktualny ekran, który go_router nam wstrzyknie.
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: child,
      // Owijamy BottomNavigationBar w Container, żeby dodać mu ładny cień na górze
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(
                0,
                -5,
              ), // Ujemny offset, żeby cień padał do góry
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0, // Cień robimy w Containerze powyżej
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          // --- STYLIZACJA KOLORÓW I TEKSTU ---
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),

          currentIndex: _calculateSelectedIndex(context),
          onTap: (int index) => _onItemTapped(index, context),
          items: const [
            // Index 0
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home),
              ), // Wypełniona ikona po kliknięciu
              label: 'Start',
            ),
            // Index 1
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_month_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_month),
              ),
              label: 'Grafik',
            ),
            // Index 2
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    // Logika podświetlania ikon w zależności od adresu URL
    if (location.startsWith('/home')) {
      return 0;
    }
    // Jeśli jesteśmy w grafiku LUB w edycji zajęć -> podświetl kalendarz
    if (location.startsWith('/schedule') ||
        location.startsWith('/add-edit-class')) {
      return 1;
    }
    // Jeśli jesteśmy w profilu, ustawieniach lub adminie -> podświetl ludzika
    if (location.startsWith('/user') ||
        location.startsWith('/admin') ||
        location.startsWith('/trainer')) {
      return 2;
    }

    return 0; // Domyślnie Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/schedule');
        break;
      case 2:
        context.go('/user');
        break;
    }
  }
}
