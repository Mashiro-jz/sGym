import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatelessWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  // --- PALETA KOLORÓW Z MOCKUPU ---
  final Color _bgColor = const Color(0xFF111812);
  final Color _surfaceColor = const Color(0xFF1E2B21);
  final Color _primaryColor = const Color(0xFF00E676);
  final Color _borderColor = const Color(0xFF2A3D2D);
  final Color _textHintColor = const Color(0xFF8B9D90);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _bgColor, // Ciemne tło zapobiegające błyskom przy ładowaniu
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _surfaceColor, // Ciemnozielone tło paska
          border: Border(
            top: BorderSide(
              color: _borderColor,
              width: 1.0,
            ), // Elegancka, cienka ramka zamiast cienia
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor:
              Colors.transparent, // Przezroczyste, by użyć koloru z Container
          type: BottomNavigationBarType.fixed,
          selectedItemColor:
              _primaryColor, // Neonowa zieleń dla wybranej zakładki
          unselectedItemColor: _textHintColor, // Szaro-zielony dla pozostałych
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900, // Grubszy font dla wybranej opcji
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
              ),
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
            // Index 2 (Karnet)
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.qr_code_scanner),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.qr_code),
              ),
              label: 'Karnet',
            ),
            // Index 3 (Profil)
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

    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/schedule') ||
        location.startsWith('/add-edit-class')) {
      return 1;
    }
    if (location.startsWith('/pass')) {
      return 2;
    }
    if (location.startsWith('/user') ||
        location.startsWith('/admin') ||
        location.startsWith('/trainer') ||
        location.startsWith('/history')) {
      // Dodano history, by nie gubiło zaznaczenia
      return 3;
    }

    return 0;
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
        context.go('/pass');
        break;
      case 3:
        context.go('/user');
        break;
    }
  }
}
