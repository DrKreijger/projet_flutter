import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverRepository {
  final FirebaseFirestore firestore;

  DriverRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Driver>> fetchDrivers() async {
    final snapshot = await firestore.collection('drivers').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Driver(
        id: doc.id,
        firstName: data['firstName'] ?? 'Inconnu',
        lastName: data['lastName'] ?? 'Inconnu',
        email: data['email'] ?? 'Non défini',
        phone: data['phoneNumber'] ?? 'Non défini',
      );
    }).toList();
  }

  Future<void> addDriver(Map<String, dynamic> driverData) async {
    await firestore.collection('drivers').add(driverData);
  }

  Future<void> updateDriver(String driverId, Map<String, dynamic> driverData) async {
    await firestore.collection('drivers').doc(driverId).update(driverData);
  }

  Future<void> deleteDriver(String driverId) async {
    await firestore.collection('drivers').doc(driverId).delete();
  }
}
