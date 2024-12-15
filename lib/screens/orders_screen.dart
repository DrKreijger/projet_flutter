import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../blocs/order_state.dart';
import '../repositories/driver_repository.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
import '../models/driver.dart';
import 'order_details_screen.dart';
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
  final DriverRepository driverRepository = DriverRepository();

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadOrders());
  }

  Future<Driver?> getDriver(String driverId) async {
    final drivers = await driverRepository.fetchDrivers();
    return drivers.firstWhere(
          (driver) => driver.id == driverId,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bons de commande'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderBloc>().add(LoadOrders());
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('Aucun bon de commande trouvé.'));
            }
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return FutureBuilder<Driver?>(
                  future: getDriver(order.driverId),
                  builder: (context, snapshot) {
                    final driver = snapshot.data;
                    return Card(
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
                            const SizedBox(height: 8),
                            // Chauffeur
                            Text(
                              'Chauffeur : ${driver?.firstName ?? "Inconnu"} ${driver?.lastName ?? ""}',
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
                                    context.read<OrderBloc>().add(UpdateOrderValidation(order.id, !order.validated));
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final drivers = await driverRepository.fetchDrivers();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderFormScreen(order: order, drivers: drivers),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    context.read<OrderBloc>().add(DeleteOrder(order.id));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is OrdersError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else {
            return const Center(child: Text('État inconnu.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final drivers = await driverRepository.fetchDrivers();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderFormScreen(drivers: drivers),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
