abstract class OrderEvent {}

class LoadOrders extends OrderEvent {}

class DeleteOrder extends OrderEvent {
  final String orderId;
  DeleteOrder(this.orderId);
}
