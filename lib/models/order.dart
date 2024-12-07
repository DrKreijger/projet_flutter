import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String clientName;
  final DateTime reservationDate;
  final String driverId;
  final bool validated;

  Order({
    required this.id,
    required this.clientName,
    required this.reservationDate,
    required this.driverId,
    required this.validated,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      clientName: map['clientName'] ?? 'Inconnu',
      reservationDate: (map['reservationDate'] as Timestamp).toDate(), // Convertit Timestamp en DateTime
      driverId: map['driverId'] ?? '',
      validated: map['validated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'reservationDate': reservationDate,
      'driverId': driverId,
      'validated': validated,
    };
  }
}
