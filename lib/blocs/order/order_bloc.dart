import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../../repositories/order_repository.dart';
import '../../models/order.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(const OrdersLoading()) {
    on<OrderLoad>(_onLoadOrders);
    on<OrderDelete>(_onDeleteOrder);
    on<OrderAdd>(_onAddOrder);
    on<OrderUpdateValidation>(_onUpdateOrderValidation);
    on<OrderUpdate>(_onUpdateOrder);
  }

  Future<void> _onLoadOrders(OrderLoad event, Emitter<OrderState> emit) async {
    try {
      emit(const OrdersLoading());
      final orders = await orderRepository.fetchOrders();

      // Trier les commandes par date dans l'ordre croissant
      orders.sort((a, b) => a.reservationDate.compareTo(b.reservationDate));

      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors du chargement des commandes : $e'));
    }
  }

  Future<void> _onDeleteOrder(OrderDelete event, Emitter<OrderState> emit) async {
    try {
      await orderRepository.deleteOrder(event.orderId);
      add(OrderLoad()); // Recharger les commandes après suppression
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors de la suppression de la commande : $e'));
    }
  }

  Future<void> _onAddOrder(OrderAdd event, Emitter<OrderState> emit) async {
    try {
      print('Ajout d\'une commande : ${event.newOrder}');
      await orderRepository.addOrder(event.newOrder.toMap());
      add(OrderLoad()); // Recharger les commandes après ajout
    } catch (e) {
      print('Erreur lors de l\'ajout de la commande : $e');
      emit(OrdersError(message: 'Impossible d\'ajouter la commande : $e'));
    }
  }

  Future<void> _onUpdateOrderValidation(OrderUpdateValidation event, Emitter<OrderState> emit) async {
    try {
      await orderRepository.updateOrderValidation(event.orderId, event.isValid);
      add(OrderLoad()); // Recharger les commandes après mise à jour
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors de la mise à jour de la validation : $e'));
    }
  }

  Future<void> _onUpdateOrder(OrderUpdate event, Emitter<OrderState> emit) async {
    try {
      await orderRepository.updateOrder(event.updatedOrder.id, event.updatedOrder.toMap());
      add(OrderLoad()); // Recharger les commandes après mise à jour
    } catch (e) {
      emit(OrdersError(message: 'Erreur lors de la mise à jour de la commande : $e'));
    }
  }
}
