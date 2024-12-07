// lib/repositories/order_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as customOrder;

class OrderRepository {
  final FirebaseFirestore firestore;

  OrderRepository({required this.firestore});

  Future<List<customOrder.Order>> fetchOrders() async {
    try {
      print('Début de fetchOrders');
      final snapshot = await firestore.collection('orders').get();
      print('Documents récupérés : ${snapshot.docs}');
      return snapshot.docs
          .map((doc) => customOrder.Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erreur dans fetchOrders : $e');
      return [];
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await firestore.collection('orders').doc(orderId).delete();
  }

  Future<void> addOrder(Map<String, dynamic> orderData) async {
    try {
      await firestore.collection('orders').add(orderData);
      print('Commande ajoutée avec succès : $orderData');
    } catch (e) {
      print('Erreur lors de l\'ajout dans Firestore : $e');
      throw e;
    }
  }

}
