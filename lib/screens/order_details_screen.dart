import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
import '../models/order.dart';
import '../models/driver.dart';
import 'order_form_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order; // La commande sélectionnée
  final List<Driver> drivers; // Liste des chauffeurs avec leurs informations

  const OrderDetailsScreen({Key? key, required this.order, required this.drivers}) : super(key: key);

  String formatDateTimeToBelgium(DateTime dateTime) {
    final tz.TZDateTime belgiumTime = tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Brussels'));
    return DateFormat('dd/MM/yyyy HH:mm').format(belgiumTime);
  }

  // Méthode pour obtenir le chauffeur correspondant
  Driver getDriver(String driverId) {
    return drivers.firstWhere(
          (d) => d.id == driverId,
      orElse: () => Driver(
        id: '',
        firstName: 'Inconnu',
        lastName: 'Chauffeur',
        email: '',
        phone: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = getDriver(order.driverId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Détails de la commande
            Text(
              'Client : ${order.clientName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date de réservation : ${formatDateTimeToBelgium(order.reservationDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Date de départ : ${formatDateTimeToBelgium(order.departureDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Affichage du chauffeur assigné
            Text(
              'Chauffeur assigné : ${driver.firstName} ${driver.lastName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'État de validation : ${order.validated ? "Validé" : "Non validé"}',
              style: TextStyle(
                fontSize: 16,
                color: order.validated ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers le formulaire d'édition
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderFormScreen(order: order, drivers: drivers),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
