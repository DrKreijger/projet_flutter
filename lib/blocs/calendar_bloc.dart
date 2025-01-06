import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Events
abstract class CalendarEvent {}

class ChangeView extends CalendarEvent {
  final CalendarView view;

  ChangeView({required this.view});
}

/// States
abstract class CalendarState {
  final CalendarView view;

  CalendarState(this.view);
}

class CalendarInitial extends CalendarState {
  CalendarInitial() : super(CalendarView.week);
}

class CalendarViewChanged extends CalendarState {
  CalendarViewChanged(CalendarView view) : super(view);
}

/// Bloc
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarInitial()) {
    on<ChangeView>((event, emit) {
      emit(CalendarViewChanged(event.view));
    });
  }
}
