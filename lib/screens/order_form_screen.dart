import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../models/order.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order; // Si null, on est en mode ajout, sinon en mode édition

  const OrderFormScreen({Key? key, this.order}) : super(key: key);

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late TextEditingController _reservationDateController;
  late TextEditingController _departureDateController;
  late TextEditingController _driverIdController;
  late bool _validated;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les données existantes ou par défaut
    _clientNameController = TextEditingController(text: widget.order?.clientName ?? '');
    _reservationDateController = TextEditingController(
      text: widget.order?.reservationDate.toIso8601String() ?? '',
    );
    _departureDateController = TextEditingController(
      text: widget.order?.departureDate.toIso8601String() ?? '',
    );
    _driverIdController = TextEditingController(text: widget.order?.driverId ?? '');
    _validated = widget.order?.validated ?? false;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _reservationDateController.dispose();
    _departureDateController.dispose();
    _driverIdController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final orderData = {
        'clientName': _clientNameController.text,
        'reservationDate': DateTime.parse(_reservationDateController.text),
        'departureDate': DateTime.parse(_departureDateController.text),
        'driverId': _driverIdController.text,
        'validated': _validated,
      };

      if (widget.order == null) {
        // Mode ajout
        context.read<OrderBloc>().add(AddOrder(orderData));
      } else {
        // Mode édition
        context.read<OrderBloc>().add(UpdateOrder(widget.order!.id, orderData));
      }

      Navigator.pop(context); // Retour à l'écran précédent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Ajouter une commande' : 'Modifier la commande'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Champ pour le nom du client
                TextFormField(
                  controller: _clientNameController,
                  decoration: InputDecoration(labelText: 'Nom du client'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom de client';
                    }
                    return null;
                  },
                ),
                // Champ pour la date de réservation
                TextFormField(
                  controller: _reservationDateController,
                  decoration: InputDecoration(labelText: 'Date de réservation (yyyy-MM-dd HH:mm:ss)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une date';
                    }
                    try {
                      DateTime.parse(value);
                    } catch (e) {
                      return 'Format de date invalide';
                    }
                    return null;
                  },
                ),
                // Champ pour la date de départ
                TextFormField(
                  controller: _departureDateController,
                  decoration: InputDecoration(labelText: 'Date de départ (yyyy-MM-dd HH:mm:ss)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une date';
                    }
                    try {
                      DateTime.parse(value);
                    } catch (e) {
                      return 'Format de date invalide';
                    }
                    return null;
                  },
                ),
                // Champ pour l'ID du chauffeur
                TextFormField(
                  controller: _driverIdController,
                  decoration: InputDecoration(labelText: 'ID du chauffeur'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un ID de chauffeur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Switch pour la validation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Validé'),
                    Switch(
                      value: _validated,
                      onChanged: (value) {
                        setState(() {
                          _validated = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Bouton pour sauvegarder
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(widget.order == null ? 'Ajouter' : 'Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
