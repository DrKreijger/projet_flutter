import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrdersLoading()) {
    on<LoadOrders>((event, emit) async {
      try {
        emit(OrdersLoading());
        final orders = await orderRepository.fetchOrders();

        // Trier les commandes par date dans l'ordre croissant (anciennes d'abord)
        orders.sort((a, b) => a.reservationDate.compareTo(b.reservationDate));

        emit(OrdersLoaded(orders));
      } catch (e) {
        emit(OrdersError('Une erreur s\'est produite lors du chargement des commandes.'));
      }
    });

    on<DeleteOrder>((event, emit) async {
      await orderRepository.deleteOrder(event.orderId);
      add(LoadOrders());
    });

    on<AddOrder>((event, emit) async {
      try {
        print('Ajout d\'une commande : ${event.orderData}');
        await orderRepository.addOrder(event.orderData);
        // Rafraîchir la liste après ajout
        add(LoadOrders());
      } catch (e) {
        print('Erreur lors de l\'ajout de la commande : $e');
        emit(OrdersError('Impossible d\'ajouter la commande.'));
      }
    });

    on<UpdateOrderValidation>((event, emit) async {
      try {
        final docRef = FirebaseFirestore.instance.collection('orders').doc(event.orderId);
        await docRef.update({'validated': event.newValidationState});
        add(LoadOrders()); // Recharge les commandes pour mettre à jour l'interface
      } catch (e) {
        emit(OrdersError('Erreur lors de la mise à jour de la validation : $e'));
      }
    });

    on<UpdateOrder>((event, emit) async {
      try {
        final docRef = FirebaseFirestore.instance.collection('orders').doc(event.orderId);
        await docRef.update(event.updatedData);
        add(LoadOrders()); // Recharge les commandes pour mettre à jour l'interface
      } catch (e) {
        emit(OrdersError('Erreur lors de la mise à jour de la commande : $e'));
      }
    });


  }
}
