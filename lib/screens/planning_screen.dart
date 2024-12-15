import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../blocs/order_bloc.dart';
import '../blocs/order_state.dart';
import '../models/order.dart';
import '../repositories/driver_repository.dart';
import 'order_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driverRepository = DriverRepository(); // Charger les chauffeurs si nécessaire

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning des navettes'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else if (state is OrdersLoaded) {
            final appointments = state.orders.map((order) {
              return Appointment(
                startTime: order.departureDate,
                endTime: order.departureDate.add(const Duration(hours: 1)),
                subject: order.clientName,
                color: order.validated ? Colors.green : Colors.red,
                notes: order.id, // Stocke l'ID du bon de commande pour référence
              );
            }).toList();

            return SfCalendar(
              view: CalendarView.week,
              dataSource: OrderDataSource(appointments),
              firstDayOfWeek: 1, // Lundi comme premier jour de la semaine
              timeSlotViewSettings: const TimeSlotViewSettings(
                timeFormat: 'HH:mm', // Format 24h pour les heures
                timeIntervalHeight: 50,
                timeTextStyle: TextStyle(fontSize: 12),
              ),
              showDatePickerButton: true,
              headerDateFormat: 'MMMM yyyy', // Format du mois en français
              todayHighlightColor: Colors.blue,
              onTap: (calendarTapDetails) async {
                if (calendarTapDetails.appointments != null) {
                  final appointment = calendarTapDetails.appointments!.first as Appointment;
                  final orderId = appointment.notes; // Récupérer l'ID du bon de commande

                  if (orderId != null) {
                    // Trouver le bon de commande correspondant
                    final order = state.orders.firstWhere((order) => order.id == orderId);

                    // Récupérer les chauffeurs avant de naviguer vers les détails
                    final drivers = await driverRepository.fetchDrivers();

                    // Naviguer vers l'écran des détails
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order, drivers: drivers),
                      ),
                    );
                  }
                }
              },
              headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              scheduleViewSettings: const ScheduleViewSettings(
                weekHeaderSettings: WeekHeaderSettings(
                  startDateFormat: 'dd/MM',
                  endDateFormat: 'dd/MM',
                  textAlign: TextAlign.center,
                ),
              ),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: true,
              ),
            );
          } else {
            return const Center(child: Text('Erreur inconnue.'));
          }
        },
      ),
    );
  }
}

class OrderDataSource extends CalendarDataSource {
  OrderDataSource(List<Appointment> source) {
    appointments = source;
  }
}
