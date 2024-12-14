part of 'driver_bloc.dart';

abstract class DriverEvent {}

class LoadDrivers extends DriverEvent {}

class AddDriver extends DriverEvent {
  final Map<String, String> driverData;

  AddDriver(this.driverData);
}

class UpdateDriver extends DriverEvent {
  final String driverId;
  final Map<String, String> driverData;

  UpdateDriver(this.driverId, this.driverData);
}

class DeleteDriver extends DriverEvent {
  final String driverId;

  DeleteDriver(this.driverId);
}
