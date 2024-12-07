import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrdersLoading()) {
    on<LoadOrders>((event, emit) async {
      try {
        print('Chargement des commandes...');
        final orders = await orderRepository.fetchOrders();
        print('Commandes récupérées : ${orders.length}');
        emit(OrdersLoaded(orders));
      } catch (e) {
        print('Erreur dans OrderBloc : $e');
        emit(OrdersLoading()); // Ou un état d'erreur personnalisé
      }
    });


    on<DeleteOrder>((event, emit) async {
      await orderRepository.deleteOrder(event.orderId);
      add(LoadOrders());
    });
  }
}
