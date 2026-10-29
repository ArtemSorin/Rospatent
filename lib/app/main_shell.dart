import 'package:flutter/material.dart';
import 'package:rospatent/features/about/presentation/about_screen.dart';
import 'package:rospatent/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';

/// Главная оболочка с нижней навигацией между разделами.
/// Экран подменяется целиком, поэтому «Избранное» перезагружается при каждом входе.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[HomePage(), FavoritePage(), AboutPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'О приложении',
          ),
        ],
      ),
    );
  }
}
