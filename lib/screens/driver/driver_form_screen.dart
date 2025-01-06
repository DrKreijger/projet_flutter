import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/driver/driver_bloc.dart';
import '../../models/driver.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver? driver; // Si null, c'est pour ajouter un chauffeur, sinon pour éditer

  const DriverFormScreen({Key? key, this.driver}) : super(key: key);

  @override
  _DriverFormScreenState createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController(); // Nouveau champ
  final TextEditingController phoneController = TextEditingController(); // Nouveau champ

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      firstNameController.text = widget.driver!.firstName;
      lastNameController.text = widget.driver!.lastName;
      emailController.text = widget.driver!.email; // Charger l'email existant
      phoneController.text = widget.driver!.phoneNumber; // Charger le téléphone existant
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driver == null ? 'Ajouter un chauffeur' : 'Modifier le chauffeur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) => value == null || value.isEmpty ? 'Le prénom est obligatoire' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Nom de famille'),
                validator: (value) => value == null || value.isEmpty ? 'Le nom est obligatoire' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'L\'email est obligatoire';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(value) ? null : 'Email invalide';
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Le numéro de téléphone est obligatoire' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final driverData = {
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'email': emailController.text,
                      'phoneNumber': phoneController.text,
                    };

                    if (widget.driver == null) {
                      // Ajouter un nouveau chauffeur
                      context.read<DriverBloc>().add(AddDriver(driverData));
                    } else {
                      // Mettre à jour un chauffeur existant
                      context.read<DriverBloc>().add(UpdateDriver(widget.driver!.id, driverData));
                    }

                    Navigator.pop(context); // Retour à l'écran précédent
                  }
                },
                child: Text(widget.driver == null ? 'Ajouter' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
