import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;
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
  Driver? driver;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    driver = _getDriverById(order.driverId);
  }

  Driver? _getDriverById(String driverId) {
    return widget.drivers.firstWhere(
          (d) => d.id == driverId,
      orElse: () => Driver(
        id: '',
        firstName: 'Non',
        lastName: 'assigné',
        email: '',
        phone: '',
      ),
    );
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
        driver = _getDriverById(order.driverId);
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
                'Adresse : ${order.clientAddress}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Téléphone : ${order.clientPhone}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Aéroport : ${order.airport}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Nombre de personnes : ${order.numberOfPeople}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Prix : ${order.price.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 16),
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
                'Chauffeur : ${driver != null ? "${driver!.firstName} ${driver!.lastName}" : "Non assigné"}',
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderFormScreen(order: order, drivers: widget.drivers),
              ),
            );

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
    final tz.TZDateTime belgiumTime = tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Brussels'));

    final String formattedTime =
        '${belgiumTime.hour.toString().padLeft(2, '0')}:${belgiumTime.minute.toString().padLeft(2, '0')}';

    final String formattedDate =
        '${belgiumTime.day.toString().padLeft(2, '0')}/${belgiumTime.month.toString().padLeft(2, '0')}/${belgiumTime.year}';

    return '$formattedDate $formattedTime';
  }
}
