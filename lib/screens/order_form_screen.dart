import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_event.dart';
import '../models/driver.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

class OrderFormScreen extends StatefulWidget {
  final Order? order;
  final List<Driver> drivers;

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
  late TextEditingController _clientAddressController;
  late TextEditingController _clientPhoneController;
  late TextEditingController _airportController;
  late TextEditingController _numberOfPeopleController;
  late TextEditingController _priceController;
  late DateTime _reservationDate;
  late DateTime _departureDate;
  String? _selectedDriverId;
  late bool _validated;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.order?.clientName ?? '');
    _clientAddressController = TextEditingController(text: widget.order?.clientAddress ?? '');
    _clientPhoneController = TextEditingController(text: widget.order?.clientPhone ?? '');
    _airportController = TextEditingController(text: widget.order?.airport ?? '');
    _numberOfPeopleController = TextEditingController(
        text: widget.order?.numberOfPeople != null ? widget.order!.numberOfPeople.toString() : '');
    _priceController = TextEditingController(
        text: widget.order?.price != null ? widget.order!.price.toStringAsFixed(2) : '');
    _reservationDate = widget.order?.reservationDate ?? DateTime.now();
    _departureDate = widget.order?.departureDate ?? DateTime.now();
    _selectedDriverId = widget.order?.driverId ?? (widget.drivers.isNotEmpty ? widget.drivers[0].id : null);
    _validated = widget.order?.validated ?? false;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _clientPhoneController.dispose();
    _airportController.dispose();
    _numberOfPeopleController.dispose();
    _priceController.dispose();
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
      final newOrder = Order(
        id: widget.order?.id ?? '',
        clientName: _clientNameController.text,
        clientAddress: _clientAddressController.text,
        clientPhone: _clientPhoneController.text,
        airport: _airportController.text,
        numberOfPeople: int.parse(_numberOfPeopleController.text),
        price: double.parse(_priceController.text),
        reservationDate: _reservationDate,
        departureDate: _departureDate,
        driverId: _selectedDriverId ?? '',
        validated: _validated,
      );

      if (widget.order == null) {
        context.read<OrderBloc>().add(OrderAdd(newOrder: newOrder));
      } else {
        context.read<OrderBloc>().add(OrderUpdate(orderId: newOrder.id, updatedOrder: newOrder));
      }

      Navigator.pop(context, true); // Retourne `true` pour indiquer qu'une modification a été effectuée
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
                _buildTextField(_clientNameController, 'Nom du client', 'Veuillez entrer un nom de client'),
                const SizedBox(height: 16),
                _buildTextField(_clientAddressController, 'Adresse du client', 'Veuillez entrer une adresse'),
                const SizedBox(height: 16),
                _buildTextField(_clientPhoneController, 'Téléphone du client', 'Veuillez entrer un numéro valide'),
                const SizedBox(height: 16),
                _buildTextField(_airportController, 'Aéroport', 'Veuillez entrer un aéroport'),
                const SizedBox(height: 16),
                _buildTextField(_numberOfPeopleController, 'Nombre de personnes', 'Veuillez entrer un nombre',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(_priceController, 'Prix', 'Veuillez entrer un prix',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Date de départ :'),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickDateAndTime,
                      child: Text(
                        formatDateTimeToBelgium(_departureDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDriverId,
                  items: widget.drivers.map((driver) {
                    return DropdownMenuItem(
                      value: driver.id,
                      child: Text('${driver.firstName} ${driver.lastName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDriverId = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Chauffeur'),
                ),
                const SizedBox(height: 16),
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

  Widget _buildTextField(TextEditingController controller, String label, String error,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return error;
        }
        return null;
      },
    );
  }
}
