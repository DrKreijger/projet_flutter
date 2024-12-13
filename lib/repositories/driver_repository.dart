import 'package:cloud_firestore/cloud_firestore.dart';

class DriverRepository {
  final FirebaseFirestore firestore;

  DriverRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, String>>> fetchDrivers() async {
    final snapshot = await firestore.collection('drivers').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'firstName': data['firstName']?.toString() ?? 'Inconnu',
        'lastName': data['lastName']?.toString() ?? 'Inconnu',
      };
    }).toList();
  }
}
