import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String clientName;
  final String clientAddress; // Nouvelle propriété : adresse du client
  final String clientPhone; // Nouvelle propriété : numéro de téléphone du client
  final String airport; // Nouvelle propriété : aéroport
  final int numberOfPeople; // Nouvelle propriété : nombre de personnes
  final double price; // Nouvelle propriété : prix
  final DateTime reservationDate;
  final DateTime departureDate;
  final String driverId;
  final bool validated;

  Order({
    required this.id,
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    required this.airport,
    required this.numberOfPeople,
    required this.price,
    required this.reservationDate,
    required this.departureDate,
    required this.driverId,
    required this.validated,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      clientName: map['clientName'] ?? 'Inconnu',
      clientAddress: map['clientAddress'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      airport: map['airport'] ?? '',
      numberOfPeople: map['numberOfPeople'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      reservationDate: (map['reservationDate'] as Timestamp).toDate(), // Convertit Timestamp en DateTime
      departureDate: (map['departureDate'] as Timestamp).toDate(), // Convertit Timestamp en DateTime
      driverId: map['driverId'] ?? '',
      validated: map['validated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'clientAddress': clientAddress,
      'clientPhone': clientPhone,
      'airport': airport,
      'numberOfPeople': numberOfPeople,
      'price': price,
      'reservationDate': reservationDate,
      'departureDate': departureDate,
      'driverId': driverId,
      'validated': validated,
    };
  }
}
