import '../../models/order.dart';

abstract class OrderEvent {}

/// Événement pour charger toutes les commandes
class OrderLoad extends OrderEvent {}

/// Événement pour supprimer une commande
class OrderDelete extends OrderEvent {
  final String orderId;

  OrderDelete({required this.orderId});
}

/// Événement pour ajouter une nouvelle commande
class OrderAdd extends OrderEvent {
  final Order newOrder;

  OrderAdd({required this.newOrder});
}

/// Événement pour mettre à jour l'état de validation d'une commande
class OrderUpdateValidation extends OrderEvent {
  final String orderId;
  final bool isValid;

  OrderUpdateValidation({required this.orderId, required this.isValid});
}

/// Événement pour mettre à jour une commande existante
class OrderUpdate extends OrderEvent {
  final String orderId;
  final Order updatedOrder;

  OrderUpdate({required this.orderId, required this.updatedOrder});
}
