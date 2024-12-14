import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/driver_bloc.dart';
import '../models/driver.dart';
import 'driver_form_screen.dart';
import 'driver_details_screen.dart';
import 'shuttles_screen.dart';

class DriversScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chauffeurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DriverBloc>().add(LoadDrivers());
            },
          ),
        ],
      ),
      body: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriversLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DriversLoaded) {
            final drivers = state.drivers; // Liste des chauffeurs
            if (drivers.isEmpty) {
              return const Center(child: Text('Aucun chauffeur trouvé.'));
            }
            return ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return ListTile(
                  onTap: () {
                    // Ouvrir les détails du chauffeur
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DriverDetailsScreen(driver: driver),
                      ),
                    );
                  },
                  title: Text('${driver.firstName} ${driver.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.directions_bus, color: Colors.purple),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShuttlesScreen(
                                driverId: driver.id,
                                driverName: '${driver.firstName} ${driver.lastName}',
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverFormScreen(driver: driver),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, driver.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is DriversError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else {
            return const Center(child: Text('État inconnu.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DriverFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fonction pour afficher une boîte de dialogue de confirmation avant la suppression
  void _showDeleteConfirmation(BuildContext context, String driverId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le chauffeur'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce chauffeur ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                context.read<DriverBloc>().add(DeleteDriver(driverId));
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}