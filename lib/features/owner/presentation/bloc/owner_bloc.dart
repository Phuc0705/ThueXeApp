import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_car.dart';
import '../../domain/usecases/get_my_cars.dart';
import '../../domain/usecases/delete_car.dart';
import '../../domain/usecases/update_car_status.dart';
import 'owner_event.dart';
import 'owner_state.dart';

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final AddCar addCar;
  final GetMyCars getMyCars;
  final DeleteCar deleteCar;
  final UpdateCarStatus updateCarStatus;
  final SupabaseClient supabase;
  late final StreamSubscription<AuthState> _authSubscription;

  OwnerBloc({
    required this.addCar,
    required this.getMyCars,
    required this.deleteCar,
    required this.updateCarStatus,
    required this.supabase,
  }) : super(OwnerInitial()) {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        emit(OwnerInitial());
      }
    });

    on<GetMyCarsEvent>(_onGetMyCars);
    on<AddCarEvent>(_onAddCar);
    on<DeleteCarEvent>(_onDeleteCar);
    on<UpdateCarStatusEvent>(_onUpdateCarStatus);
  }

  Future<void> _onGetMyCars(GetMyCarsEvent event, Emitter<OwnerState> emit) async {
    emit(OwnerLoading());
    final result = await getMyCars();
    result.fold(
      (failure) => emit(const OwnerError(message: 'Lỗi khi tải danh sách xe')),
      (cars) => emit(OwnerCarsLoaded(cars: cars)),
    );
  }

  Future<void> _onAddCar(AddCarEvent event, Emitter<OwnerState> emit) async {
    emit(OwnerLoading());
    final result = await addCar(AddCarParams(
      name: event.name,
      brand: event.brand,
      pricePerDay: event.pricePerDay,
      type: event.type,
      fuelType: event.fuelType,
      transmission: event.transmission,
      location: event.location,
      description: event.description,
      seats: event.seats,
      carImage: event.carImage,
      docFrontImage: event.docFrontImage,
      docBackImage: event.docBackImage,
    ));

    result.fold(
      (failure) => emit(OwnerError(message: 'Lỗi: ${failure.message}')),
      (car) => emit(OwnerCarAddedSuccess(car: car)),
    );
  }

  Future<void> _onDeleteCar(DeleteCarEvent event, Emitter<OwnerState> emit) async {
    emit(OwnerLoading());
    final result = await deleteCar(event.carId);
    result.fold(
      (failure) => emit(const OwnerError(message: 'Lỗi khi xoá xe')),
      (_) => emit(OwnerCarDeletedSuccess()),
    );
  }

  Future<void> _onUpdateCarStatus(UpdateCarStatusEvent event, Emitter<OwnerState> emit) async {
    emit(OwnerLoading());
    final result = await updateCarStatus(event.carId, event.status);
    result.fold(
      (failure) => emit(OwnerError(message: 'Lỗi cập nhật: ${failure.message}')),
      (_) => emit(OwnerCarStatusUpdatedSuccess()),
    );
  }
}
