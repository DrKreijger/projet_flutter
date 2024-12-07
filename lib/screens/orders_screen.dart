import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../blocs/order_state.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
                  title: Text(order.clientName),
                  subtitle: Text(order.reservationDate.toIso8601String()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      print('Suppression de la commande ID: ${order.id}');
                      context.read<OrderBloc>().add(DeleteOrder(order.id));
                    },
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
        onPressed: () {
          print('Bouton d\'ajout pressé');
          final hardcodedOrder = {
            'clientName': 'Commande Test',
            'reservationDate': Timestamp.now(), // Timestamp Firestore
            'driverId': 'driver1',
            'validated': false,
          };
          context.read<OrderBloc>().add(AddOrder(hardcodedOrder));
        },
        child: Icon(Icons.add),
      ),

    );
  }
}
