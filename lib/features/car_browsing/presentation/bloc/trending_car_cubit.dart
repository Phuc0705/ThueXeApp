import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_trending_cars.dart';
import 'trending_car_state.dart';

class TrendingCarCubit extends Cubit<TrendingCarState> {
  final GetTrendingCars getTrendingCars;

  TrendingCarCubit({required this.getTrendingCars}) : super(TrendingCarInitial());

  Future<void> fetchTrendingCars() async {
    emit(TrendingCarLoading());
    final result = await getTrendingCars(limit: 5);
    result.fold(
      (failure) {
        print('TrendingCarCubit Error: ${failure.message}');
        emit(TrendingCarError(failure.message));
      },
      (cars) => emit(TrendingCarLoaded(cars)),
    );
  }
}
