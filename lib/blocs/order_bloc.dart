import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(const OrdersLoading()) {
    on<LoadOrders>(_onLoadOrders);
    on<DeleteOrder>(_onDeleteOrder);
    on<AddOrder>(_onAddOrder);
    on<UpdateOrderValidation>(_onUpdateOrderValidation);
    on<UpdateOrder>(_onUpdateOrder);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) async {
    try {
      emit(const OrdersLoading());
      final orders = await orderRepository.fetchOrders();

      // Trier les commandes par date dans l'ordre croissant (anciennes d'abord)
      orders.sort((a, b) => a.reservationDate.compareTo(b.reservationDate));

      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: 'Une erreur s\'est produite lors du chargement des commandes : $e'));
    }
  }

  Future<void> _onDeleteOrder(DeleteOrder event, Emitter<OrderState> emit) async {
    try {
      await orderRepository.deleteOrder(event.orderId);
      add(LoadOrders()); // Recharger les commandes après suppression
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors de la suppression de la commande : $e'));
    }
  }

  Future<void> _onAddOrder(AddOrder event, Emitter<OrderState> emit) async {
    try {
      print('Ajout d\'une commande : ${event.orderData}');
      await orderRepository.addOrder(event.orderData);
      add(LoadOrders()); // Recharger les commandes après ajout
    } catch (e) {
      print('Erreur lors de l\'ajout de la commande : $e');
      emit(OrdersError(message: 'Impossible d\'ajouter la commande : $e'));
    }
  }

  Future<void> _onUpdateOrderValidation(UpdateOrderValidation event, Emitter<OrderState> emit) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('orders').doc(event.orderId);
      await docRef.update({'validated': event.newValidationState});
      add(LoadOrders()); // Recharger les commandes après mise à jour
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors de la mise à jour de la validation : $e'));
    }
  }

  Future<void> _onUpdateOrder(UpdateOrder event, Emitter<OrderState> emit) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('orders').doc(event.orderId);
      await docRef.update(event.updatedData);
      add(LoadOrders()); // Recharger les commandes après mise à jour
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors de la mise à jour de la commande : $e'));
    }
  }
}
