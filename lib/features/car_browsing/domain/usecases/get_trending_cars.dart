import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/car.dart';
import '../repositories/car_repository.dart';

class GetTrendingCars {
  final CarRepository repository;

  GetTrendingCars(this.repository);

  Future<Either<Failure, List<Car>>> call({int limit = 5}) async {
    return await repository.getTrendingCars(limit: limit);
  }
}
