import '../models/order.dart';

abstract class OrderState {}

class OrdersLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  OrdersLoaded(this.orders);
}

class OrdersError extends OrderState {
  final String message; // Message d'erreur
  OrdersError(this.message);
}
