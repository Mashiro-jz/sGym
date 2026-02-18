import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatelessWidget {
  // To "child" to jest właśnie aktualny ekran, który go_router nam wstrzyknie.
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        // Ważne przy 3+ elementach: type: fixed zapobiega "tańczeniu" ikon
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        items: const [
          // Index 0
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Start'),
          // Index 1 (NOWY)
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Grafik',
          ),
          // Index 2
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
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
    if (location.startsWith('/user') || location.startsWith('/admin')) {
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
        context.go('/schedule'); // <--- Przejście do Grafiku
        break;
      case 2:
        context.go('/user');
        break;
    }
  }
}
