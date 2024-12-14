import 'package:flutter/material.dart';
import '../screens/orders_screen.dart';
import '../screens/drivers_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    OrdersScreen(), // Écran des bons de commande
    DriversScreen(), // Écran des chauffeurs
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
        ],
      ),
    );
  }
}
