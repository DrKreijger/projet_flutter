import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_event.dart';
import '../blocs/order/order_state.dart';
import '../models/order.dart';
import '../repositories/driver_repository.dart';
import 'order/order_details_screen.dart';
import '../blocs/calendar_bloc.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driverRepository = DriverRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning des navettes'),
        actions: [
          BlocBuilder<CalendarBloc, CalendarState>(
            builder: (context, calendarState) {
              return DropdownButton<CalendarView>(
                value: calendarState.view, // Synchronise avec l'état actuel
                items: const [
                  DropdownMenuItem(
                    value: CalendarView.day,
                    child: Text('Vue journalière'),
                  ),
                  DropdownMenuItem(
                    value: CalendarView.week,
                    child: Text('Vue hebdomadaire'),
                  ),
                ],
                onChanged: (view) {
                  if (view != null) {
                    context.read<CalendarBloc>().add(ChangeView(view: view));
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<CalendarBloc, CalendarState>(
        listener: (context, calendarState) {
          // Forcer une reconstruction dès qu'une vue est changée
          context.read<OrderBloc>().add(OrderLoad()); // Optionnel si des données dynamiques doivent être rechargées
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            if (orderState is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (orderState is OrdersError) {
              return Center(child: Text('Erreur : ${orderState.message}'));
            } else if (orderState is OrdersLoaded) {
              final appointments = orderState.orders.map((order) {
                return Appointment(
                  startTime: order.departureDate,
                  endTime: order.departureDate.add(const Duration(hours: 1)),
                  subject: order.clientName,
                  color: order.validated ? Colors.green : Colors.red,
                  notes: order.id,
                );
              }).toList();

              return BlocBuilder<CalendarBloc, CalendarState>(
                builder: (context, calendarState) {
                  return SfCalendar(
                    view: calendarState.view, // Vue synchronisée
                    dataSource: OrderDataSource(appointments),
                    firstDayOfWeek: 1,
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      timeFormat: 'HH:mm',
                      timeIntervalHeight: 50,
                      timeTextStyle: TextStyle(fontSize: 12),
                    ),
                    todayHighlightColor: Colors.blue,
                    headerDateFormat: 'MMMM yyyy',
                    onTap: (calendarTapDetails) async {
                      if (calendarTapDetails.appointments != null) {
                        final appointment =
                        calendarTapDetails.appointments!.first as Appointment;
                        final orderId = appointment.notes;

                        if (orderId != null) {
                          final order = orderState.orders
                              .firstWhere((order) => order.id == orderId);
                          final drivers = await driverRepository.fetchDrivers();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(
                                order: order,
                                drivers: drivers,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    headerStyle: const CalendarHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Erreur inconnue.'));
            }
          },
        ),
      ),
    );
  }
}

class OrderDataSource extends CalendarDataSource {
  OrderDataSource(List<Appointment> source) {
    appointments = source;
  }
}
