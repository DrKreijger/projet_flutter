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

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrdersLoaded) {
          // Mettre à jour les détails si la commande a été modifiée
          final updatedOrder = state.orders.firstWhere(
                (o) => o.id == order.id,
            orElse: () => order,
          );
          setState(() {
            order = updatedOrder;
          });
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
              Text('Date de réservation : ${order.reservationDate}'),
              const SizedBox(height: 8),
              Text('Date de départ : ${order.departureDate}'),
              const SizedBox(height: 8),
              Text('État de validation : ${order.validated ? "Validé" : "Non validé"}'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Naviguer vers le formulaire d'édition
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderFormScreen(order: order, drivers: widget.drivers),
              ),
            ).then((_) {
              // Émettre un événement pour recharger les commandes après l'édition
              context.read<OrderBloc>().add(LoadOrders());
            });
          },
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
