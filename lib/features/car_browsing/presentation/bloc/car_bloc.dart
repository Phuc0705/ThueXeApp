<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_cars.dart';
import 'car_event.dart';
import 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCars;

  CarBloc({required this.getCars}) : super(CarInitial()) {
    on<FetchCarsEvent>((event, emit) async {
      emit(CarLoading());
      final result = await getCars(CarFilterParams(
        query: event.query,
        type: event.type,
        fuelType: event.fuelType,
        transmission: event.transmission,
        maxPrice: event.maxPrice,
      ));
      result.fold(
        (failure) => emit(CarError(failure.message)),
        (cars) => emit(CarLoaded(cars)),
      );
    });
  }
}
=======
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_cars.dart';
import 'car_event.dart';
import 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCars getCars;

  CarBloc({required this.getCars}) : super(CarInitial()) {
    on<FetchCarsEvent>((event, emit) async {
      emit(CarLoading());
      final result = await getCars(CarFilterParams(
        query: event.query,
        type: event.type,
        fuelType: event.fuelType,
        transmission: event.transmission,
        maxPrice: event.maxPrice,
      ));
      result.fold(
        (failure) => emit(CarError(failure.message)),
        (cars) => emit(CarLoaded(cars)),
      );
    });
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
