<<<<<<< HEAD
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class CarFilterParams {
  final String? query;
  final String? type;
  final String? fuelType;
  final String? transmission;
  final double? maxPrice;

  CarFilterParams({
    this.query,
    this.type,
    this.fuelType,
    this.transmission,
    this.maxPrice,
  });
}

class GetCars implements UseCase<List<Car>, CarFilterParams> {
  final CarRepository repository;

  GetCars(this.repository);

  @override
  Future<Either<Failure, List<Car>>> call(CarFilterParams params) async {
    return await repository.getCars(
      query: params.query,
      type: params.type,
      fuelType: params.fuelType,
      transmission: params.transmission,
      maxPrice: params.maxPrice,
    );
  }
}
=======
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class CarFilterParams {
  final String? query;
  final String? type;
  final String? fuelType;
  final String? transmission;
  final double? maxPrice;

  CarFilterParams({
    this.query,
    this.type,
    this.fuelType,
    this.transmission,
    this.maxPrice,
  });
}

class GetCars implements UseCase<List<Car>, CarFilterParams> {
  final CarRepository repository;

  GetCars(this.repository);

  @override
  Future<Either<Failure, List<Car>>> call(CarFilterParams params) async {
    return await repository.getCars(
      query: params.query,
      type: params.type,
      fuelType: params.fuelType,
      transmission: params.transmission,
      maxPrice: params.maxPrice,
    );
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
