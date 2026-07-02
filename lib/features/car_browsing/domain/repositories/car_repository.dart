import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/car.dart';

abstract class CarRepository {
  Future<Either<Failure, List<Car>>> getCars({
    String? query,
    String? type,
    String? fuelType,
    String? transmission,
    double? maxPrice,
  });
}
