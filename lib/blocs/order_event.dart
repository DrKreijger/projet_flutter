abstract class OrderEvent {}

class LoadOrders extends OrderEvent {}

class DeleteOrder extends OrderEvent {
  final String orderId;
  DeleteOrder(this.orderId);
}
class AddOrder extends OrderEvent {
  final Map<String, dynamic> orderData; // Les données de la commande
  AddOrder(this.orderData);
}

class UpdateOrderValidation extends OrderEvent {
  final String orderId;
  final bool newValidationState;

  UpdateOrderValidation(this.orderId, this.newValidationState);
}

