import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../repositories/order_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrdersLoading()) {
    on<LoadOrders>((event, emit) async {
      print('LoadOrders déclenché');
      try {
        emit(OrdersLoading());
        final orders = await orderRepository.fetchOrders();
        print('Commandes récupérées : ${orders.length}');
        emit(OrdersLoaded(orders));
      } catch (e) {
        print('Erreur dans LoadOrders : $e');
        emit(OrdersError('Une erreur s\'est produite.'));
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

  }
}
