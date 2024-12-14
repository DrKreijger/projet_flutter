class Driver {
  final String id;
  final String firstName;
  final String lastName;
  final String email; // Nouveau champ
  final String phone; // Nouveau champ

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory Driver.fromMap(Map<String, dynamic> map, String id) {
    return Driver(
      id: id,
      firstName: map['firstName'] ?? 'Inconnu',
      lastName: map['lastName'] ?? 'Inconnu',
      email: map['email'] ?? 'Inconnu', // Par défaut "Inconnu"
      phone: map['phone'] ?? 'Inconnu', // Par défaut "Inconnu"
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email, // Ajoute l'email
      'phone': phone, // Ajoute le numéro de téléphone
    };
  }
}
