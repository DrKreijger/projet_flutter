import 'package:flutter/material.dart';
import '../screens/orders_screen.dart';
import '../screens/drivers_screen.dart';
import '../screens/planning_screen.dart'; // Nouvel écran à inclure

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // Ajout de l'écran du planning dans la liste des écrans
  final List<Widget> _screens = [
    OrdersScreen(), // Écran des bons de commande
    DriversScreen(), // Écran des chauffeurs
    PlanningScreen(), // Nouvel écran du planning des navettes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Bons de commande',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Chauffeurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planning',
          ),
        ],
      ),
    );
  }
}
