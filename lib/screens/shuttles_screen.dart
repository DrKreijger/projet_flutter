import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_event.dart';
import '../blocs/order/order_state.dart';
import '../models/order.dart';
import 'order/order_form_screen.dart';
import 'order/order_details_screen.dart';
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
              context.read<OrderBloc>().add(OrderLoad()); // Utiliser le nouvel événement `OrderLoad`
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
            final filteredOrders = state.orders.where((order) => order.driverId == driverId).toList();

            if (filteredOrders.isEmpty) {
              return const Center(child: Text('Aucune navette trouvée pour ce chauffeur.'));
            }

            return ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order, drivers: []),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client
                          Text(
                            'Client : ${order.clientName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Départ
                          Text(
                            'Départ : ${formatDateTimeToBelgium(order.departureDate)}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          // Boutons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  order.validated ? Icons.check_circle : Icons.cancel,
                                  color: order.validated ? Colors.green : Colors.red,
                                ),
                                onPressed: () {
                                  context
                                      .read<OrderBloc>()
                                      .add(OrderUpdateValidation(orderId: order.id, isValid: !order.validated));
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
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
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  context.read<OrderBloc>().add(OrderDelete(orderId: order.id));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
