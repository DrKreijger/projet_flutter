import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;


class OrderFormScreen extends StatefulWidget {
  final Order? order; // Si null, on est en mode ajout, sinon en mode édition
  final List<Map<String, String>> drivers; // Liste des chauffeurs avec leur ID, nom, prénom

  const OrderFormScreen({Key? key, this.order, required this.drivers}) : super(key: key);

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

String formatDateTimeToBelgium(DateTime dateTime) {
  final tz.TZDateTime belgiumTime = tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Brussels'));
  return DateFormat('dd/MM/yyyy HH:mm').format(belgiumTime);
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clientNameController;
  late DateTime _reservationDate;
  late DateTime _departureDate;
  String? _selectedDriverId;
  late bool _validated;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.order?.clientName ?? '');
    _reservationDate = widget.order?.reservationDate ?? DateTime.now();
    _departureDate = widget.order?.departureDate ?? DateTime.now();
    _selectedDriverId = widget.order?.driverId;
    _validated = widget.order?.validated ?? false;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    super.dispose();
  }

  void _pickDateAndTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_departureDate),
      );

      if (pickedTime != null) {
        setState(() {
          _departureDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final orderData = {
        'clientName': _clientNameController.text,
        'reservationDate': _reservationDate,
        'departureDate': _departureDate,
        'driverId': _selectedDriverId,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date de réservation :'),
                    Text(
                      formatDateTimeToBelgium(_reservationDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nom du client
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
                const SizedBox(height: 16),
                // Date de départ (avec sélecteur)
                Row(
                  children: [
                    const Text('Date de départ :'),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickDateAndTime,
                      child: Text(
                        formatDateTimeToBelgium(_departureDate), // Affichage formaté
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Sélecteur de chauffeur
                DropdownButtonFormField<String>(
                  value: _selectedDriverId,
                  decoration: const InputDecoration(labelText: 'Chauffeur'),
                  items: widget.drivers.map((driver) {
                    return DropdownMenuItem<String>(
                      value: driver['id'], // ID du chauffeur
                      child: Text('${driver['firstName']} ${driver['lastName']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDriverId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un chauffeur';
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
