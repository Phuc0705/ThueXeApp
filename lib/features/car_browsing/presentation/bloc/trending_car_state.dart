import 'package:equatable/equatable.dart';
import '../../domain/entities/car.dart';

abstract class TrendingCarState extends Equatable {
  const TrendingCarState();

  @override
  List<Object> get props => [];
}

class TrendingCarInitial extends TrendingCarState {}

class TrendingCarLoading extends TrendingCarState {}

class TrendingCarLoaded extends TrendingCarState {
  final List<Car> cars;

  const TrendingCarLoaded(this.cars);

  @override
  List<Object> get props => [cars];
}

class TrendingCarError extends TrendingCarState {
  final String message;

  const TrendingCarError(this.message);

  @override
  List<Object> get props => [message];
}
