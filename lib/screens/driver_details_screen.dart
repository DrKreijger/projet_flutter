import 'package:flutter/material.dart';
import '../models/driver.dart';
import 'driver_form_screen.dart';

class DriverDetailsScreen extends StatelessWidget {
  final Driver driver; // Le chauffeur sélectionné

  const DriverDetailsScreen({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du chauffeur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage des détails du chauffeur
            Text(
              'Prénom : ${driver.firstName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nom : ${driver.lastName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Email : ${driver.email}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Numéro de téléphone : ${driver.phone}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers le formulaire pour éditer les détails du chauffeur
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DriverFormScreen(driver: driver),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
