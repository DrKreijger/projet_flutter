import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../blocs/order_state.dart';
import '../repositories/driver_repository.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
import 'order_form_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

String formatDateTimeToBelgium(DateTime dateTime) {
  final tz.TZDateTime belgiumTime = tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Brussels'));
  return DateFormat('dd/MM/yyyy HH:mm').format(belgiumTime);
}

class _OrdersScreenState extends State<OrdersScreen> {
  final DriverRepository driverRepository = DriverRepository(); // Repository pour gérer les chauffeurs

  @override
  void initState() {
    super.initState();
    // Déclenche LoadOrders au démarrage
    print('Déclenchement de LoadOrders au démarrage');
    context.read<OrderBloc>().add(LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bons de commande'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('Bouton de rafraîchissement pressé');
              context.read<OrderBloc>().add(LoadOrders());
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            print('État OrdersLoading détecté');
            return Center(child: CircularProgressIndicator());
          } else if (state is OrdersLoaded) {
            print('État OrdersLoaded détecté : ${state.orders.length} commandes');
            if (state.orders.isEmpty) {
              print('Aucune commande trouvée');
              return Center(child: Text('Aucun bon de commande trouvé.'));
            }
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                print('Commande affichée : ${order.clientName}, ID: ${order.id}');
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0), // Augmente l'espacement
                  title: Text(order.clientName), // Nom du client
                  subtitle: Text(
                    formatDateTimeToBelgium(order.departureDate),
                    style: TextStyle(color: Colors.grey, fontSize: 12), // Date sous le nom
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Évite que la `Row` prenne tout l'espace horizontal
                    mainAxisAlignment: MainAxisAlignment.center, // Centre les icônes horizontalement
                    children: [
                      // Icône de validation (cliquable)
                      IconButton(
                        padding: EdgeInsets.zero, // Supprime les marges internes
                        constraints: BoxConstraints(), // Réduit les contraintes
                        icon: Icon(
                          order.validated ? Icons.check_circle : Icons.cancel,
                          color: order.validated ? Colors.green : Colors.red,
                          size: 20, // Taille de l'icône
                        ),
                        onPressed: () {
                          print('Changement d\'état de validation pour la commande ID: ${order.id}');
                          // Inversion de l'état de validation
                          context.read<OrderBloc>().add(UpdateOrderValidation(order.id, !order.validated));
                        },
                      ),
                      const SizedBox(width: 16), // Espacement entre les icônes
                      // Icône de suppression
                      IconButton(
                        padding: EdgeInsets.zero, // Supprime les marges internes
                        constraints: BoxConstraints(), // Réduit les contraintes
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          print('Suppression de la commande ID: ${order.id}');
                          context.read<OrderBloc>().add(DeleteOrder(order.id));
                        },
                      ),
                      const SizedBox(width: 8), // Espacement entre les icônes
                      // Icône d'édition
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () async {
                          // Récupère les chauffeurs avant d'ouvrir le formulaire
                          final drivers = await driverRepository.fetchDrivers();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderFormScreen(order: order, drivers: drivers),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is OrdersError) {
            print('État OrdersError détecté : ${state.message}');
            return Center(child: Text('Erreur : ${state.message}'));
          } else {
            print('État inconnu détecté');
            return Center(child: Text('Erreur inconnue.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Récupère les chauffeurs avant d'ouvrir le formulaire
          final drivers = await driverRepository.fetchDrivers();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderFormScreen(drivers: drivers),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}