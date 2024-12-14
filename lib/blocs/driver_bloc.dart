import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/driver.dart';
import '../repositories/driver_repository.dart';

part 'driver_event.dart';
part 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepository driverRepository;

  DriverBloc({required this.driverRepository}) : super(DriversLoading()) {
    on<LoadDrivers>(_onLoadDrivers);
    on<AddDriver>(_onAddDriver);
    on<UpdateDriver>(_onUpdateDriver);
    on<DeleteDriver>(_onDeleteDriver);
  }

  Future<void> _onLoadDrivers(LoadDrivers event, Emitter<DriverState> emit) async {
    emit(DriversLoading());
    try {
      final drivers = await driverRepository.fetchDrivers();
      emit(DriversLoaded(drivers));
    } catch (e) {
      emit(DriversError('Erreur lors du chargement des chauffeurs : $e'));
    }
  }

  Future<void> _onAddDriver(AddDriver event, Emitter<DriverState> emit) async {
    try {
      await driverRepository.addDriver(event.driverData);
      add(LoadDrivers()); // Recharge la liste après ajout
    } catch (e) {
      emit(DriversError('Erreur lors de l\'ajout du chauffeur : $e'));
    }
  }

  Future<void> _onUpdateDriver(UpdateDriver event, Emitter<DriverState> emit) async {
    try {
      await driverRepository.updateDriver(event.driverId, event.driverData);
      add(LoadDrivers()); // Recharge la liste après modification
    } catch (e) {
      emit(DriversError('Erreur lors de la mise à jour du chauffeur : $e'));
    }
  }

  Future<void> _onDeleteDriver(DeleteDriver event, Emitter<DriverState> emit) async {
    try {
      await driverRepository.deleteDriver(event.driverId);
      add(LoadDrivers()); // Recharge la liste après suppression
    } catch (e) {
      emit(DriversError('Erreur lors de la suppression du chauffeur : $e'));
    }
  }
}
