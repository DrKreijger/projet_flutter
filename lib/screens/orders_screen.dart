import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../blocs/order_state.dart';
import '../repositories/driver_repository.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bons de commande'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderBloc>().add(LoadOrders());
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(child: Text('Aucun bon de commande trouvé.'));
            }
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Ajoute un padding uniforme
                  onTap: () async {
                    final drivers = await driverRepository.fetchDrivers();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order, drivers: drivers),
                      ),
                    );
                  },
                  title: Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    formatDateTimeToBelgium(order.departureDate),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
                          icon: Icon(Icons.edit, color: Colors.blue),
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
                      ),
                      const SizedBox(width: 8), // Espacement entre les boutons
                      // Icône de suppression
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<OrderBloc>().add(DeleteOrder(order.id));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is OrdersError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else {
            return Center(child: Text('État inconnu.'));
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
        child: Icon(Icons.add),
      ),
    );
  }
}
