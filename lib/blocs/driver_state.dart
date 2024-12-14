part of 'driver_bloc.dart';

abstract class DriverState {}

class DriversLoading extends DriverState {}

class DriversLoaded extends DriverState {
  final List<Driver> drivers; // Utilise List<Driver>

  DriversLoaded(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

class DriversError extends DriverState {
  final String message;

  DriversError(this.message);

  @override
  List<Object?> get props => [message];
}
