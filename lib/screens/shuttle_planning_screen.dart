import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_state.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

class ShuttlePlanningScreen extends StatelessWidget {
  String formatDateTimeToBelgium(DateTime dateTime) {
    final tz.TZDateTime belgiumTime = tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Brussels'));
    return DateFormat('dd/MM/yyyy HH:mm').format(belgiumTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning des navettes'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersLoaded) {
            final orders = state.orders;

            if (orders.isEmpty) {
              return const Center(child: Text('Aucune navette à afficher.'));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Client : ${order.clientName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Départ : ${formatDateTimeToBelgium(order.departureDate)}'),
                        Text('Chauffeur : ${order.driverId}'), // Ajouter un mapping pour afficher le nom
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is OrdersError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else {
            return const Center(child: Text('Erreur inconnue.'));
          }
        },
      ),
    );
  }
}
