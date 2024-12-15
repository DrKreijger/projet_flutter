import '../models/order.dart';

abstract class OrderState {
  const OrderState(); // Utilisation d'un constructeur constant pour les classes abstraites
}

class OrdersLoading extends OrderState {
  const OrdersLoading(); // Marquer l'état comme constant
}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  const OrdersLoaded({required this.orders});

  OrdersLoaded copyWith({List<Order>? orders}) {
    return OrdersLoaded(orders: orders ?? this.orders);
  }
}

class OrdersError extends OrderState {
  final String message; // Message d'erreur
  const OrdersError({required this.message});
}
