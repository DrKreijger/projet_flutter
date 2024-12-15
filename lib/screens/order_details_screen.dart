import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_event.dart';
import '../models/order.dart';
import '../models/driver.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_state.dart';
import 'order_form_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  final List<Driver> drivers;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
    required this.drivers,
  }) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  void _updateOrderDetails(BuildContext context) {
    final blocState = context.read<OrderBloc>().state;
    if (blocState is OrdersLoaded) {
      final updatedOrder = blocState.orders.firstWhere(
            (o) => o.id == order.id,
        orElse: () => order,
      );
      setState(() {
        order = updatedOrder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrdersLoaded) {
          _updateOrderDetails(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la commande'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          onPressed: () async {
            // Naviguer vers le formulaire d'édition
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OrderFormScreen(order: order, drivers: widget.drivers),
              ),
            );

            // Recharger les commandes si une mise à jour a été effectuée
            if (result == true) {
              context.read<OrderBloc>().add(OrderLoad());
            }
          },
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }

  String formatDateTimeToBelgium(DateTime dateTime) {
    // Implémenter la logique de formatage
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
