import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/driver.dart';
import '../../blocs/driver/driver_bloc.dart';
import 'driver_form_screen.dart';

class DriverDetailsScreen extends StatefulWidget {
  final Driver driver;

  const DriverDetailsScreen({Key? key, required this.driver}) : super(key: key);

  @override
  _DriverDetailsScreenState createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  late Driver driver;

  @override
  void initState() {
    super.initState();
    driver = widget.driver;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state is DriversLoaded) {
          // Rechercher et mettre à jour les détails du chauffeur
          final updatedDriver = state.drivers.firstWhere(
                (d) => d.id == driver.id,
            orElse: () => driver, // Garder le chauffeur actuel s'il n'est pas trouvé
          );
          setState(() {
            driver = updatedDriver;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails du chauffeur'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prénom : ${driver.firstName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Nom : ${driver.lastName}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Email : ${driver.email}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Numéro de téléphone : ${driver.phone}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Naviguer vers le formulaire d'édition
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverFormScreen(driver: driver),
              ),
            ).then((_) {
              // Charger les chauffeurs après l'édition
              context.read<DriverBloc>().add(LoadDrivers());
            });
          },
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}