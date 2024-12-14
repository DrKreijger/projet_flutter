import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../blocs/order_state.dart';
import '../models/order.dart';
import 'order_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

class ShuttlesScreen extends StatelessWidget {
  final String driverId; // ID du chauffeur pour lequel afficher les navettes
  final String driverName; // Nom complet du chauffeur (prénom + nom)

  const ShuttlesScreen({Key? key, required this.driverId, required this.driverName}) : super(key: key);

  String formatDateTimeToBelgium(DateTime dateTime) {
    final tz.TZDateTime belgiumTime = tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Brussels'));
    return DateFormat('dd/MM/yyyy HH:mm').format(belgiumTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navettes de $driverName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderBloc>().add(LoadOrders()); // Recharger toutes les commandes
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else if (state is OrdersLoaded) {
            // Filtrer les commandes associées au chauffeur
            final filteredOrders = state.orders.where((order) => order.driverId == driverId).toList();

            if (filteredOrders.isEmpty) {
              return const Center(child: Text('Aucune navette trouvée pour ce chauffeur.'));
            }

            return ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Uniformise le padding
                  title: Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold)), // Nom du client
                  subtitle: Text(
                    formatDateTimeToBelgium(order.departureDate), // Date de départ
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône de validation
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            order.validated ? Icons.check_circle : Icons.cancel,
                            color: order.validated ? Colors.green : Colors.red,
                          ),
                          onPressed: () {
                            print('Changement d\'état de validation pour la commande ID: ${order.id}');
                            context.read<OrderBloc>().add(UpdateOrderValidation(order.id, !order.validated));
                          },
                        ),
                      ),
                      const SizedBox(width: 8), // Espacement entre les boutons
                      // Icône d'édition
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderFormScreen(order: order, drivers: []),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8), // Espacement entre les boutons
                      // Icône de suppression
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            print('Suppression de la commande ID: ${order.id}');
                            context.read<OrderBloc>().add(DeleteOrder(order.id));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Erreur inconnue.'));
          }
        },
      ),
    );
  }
}
