import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';
import '../datasources/car_remote_data_source.dart';

class CarRepositoryImpl implements CarRepository {
  final CarRemoteDataSource remoteDataSource;

  CarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Car>>> getCars({
    String? query,
    String? type,
    String? fuelType,
    String? transmission,
    double? maxPrice,
  }) async {
    try {
      final cars = await remoteDataSource.getCars(
        query: query,
        type: type,
        fuelType: fuelType,
        transmission: transmission,
        maxPrice: maxPrice,
      );
      return Right(cars);
    } catch (e) {
      return Left(ServerFailure('Không thể tải danh sách xe: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getTrendingCars({int limit = 5}) async {
    try {
      final cars = await remoteDataSource.getTrendingCars(limit: limit);
      return Right(cars);
    } catch (e) {
      return Left(ServerFailure('Không thể tải danh sách xe xu hướng: $e'));
    }
  }
}
