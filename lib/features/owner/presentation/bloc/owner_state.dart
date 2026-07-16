import 'package:equatable/equatable.dart';
import '../../../car_browsing/domain/entities/car.dart';

abstract class OwnerState extends Equatable {
  const OwnerState();

  @override
  List<Object?> get props => [];
}

class OwnerInitial extends OwnerState {}

class OwnerLoading extends OwnerState {}

class OwnerCarsLoaded extends OwnerState {
  final List<Car> cars;

  const OwnerCarsLoaded({required this.cars});

  @override
  List<Object?> get props => [cars];
}

class OwnerCarAddedSuccess extends OwnerState {
  final Car car;

  const OwnerCarAddedSuccess({required this.car});

  @override
  List<Object?> get props => [car];
}

class OwnerError extends OwnerState {
  final String message;

  const OwnerError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OwnerCarDeletedSuccess extends OwnerState {}

class OwnerCarStatusUpdatedSuccess extends OwnerState {}
