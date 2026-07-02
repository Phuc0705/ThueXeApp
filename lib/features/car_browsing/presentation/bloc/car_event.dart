import 'package:equatable/equatable.dart';

abstract class CarEvent extends Equatable {
  const CarEvent();

  @override
  List<Object> get props => [];
}

class FetchCarsEvent extends CarEvent {
  final String? query;
  final String? type;
  final String? fuelType;
  final String? transmission;
  final double? maxPrice;

  const FetchCarsEvent({
    this.query,
    this.type,
    this.fuelType,
    this.transmission,
    this.maxPrice,
  });

  @override
  List<Object> get props => [
        query ?? '',
        type ?? '',
        fuelType ?? '',
        transmission ?? '',
        maxPrice ?? 0,
      ];
}
