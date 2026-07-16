import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../car_browsing/domain/entities/car.dart';
import '../../domain/repositories/owner_repository.dart';
import '../datasources/owner_remote_data_source.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  final OwnerRemoteDataSource remoteDataSource;

  OwnerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Car>> addCar({
    required String name,
    required String brand,
    required double pricePerDay,
    required String type,
    required String fuelType,
    required String transmission,
    required String location,
    required String description,
    required int seats,
    required XFile carImage,
    required XFile docFrontImage,
    required XFile docBackImage,
  }) async {
    try {
      final car = await remoteDataSource.addCar(
        name: name,
        brand: brand,
        pricePerDay: pricePerDay,
        type: type,
        fuelType: fuelType,
        transmission: transmission,
        location: location,
        description: description,
        seats: seats,
        carImage: carImage,
        docFrontImage: docFrontImage,
        docBackImage: docBackImage,
      );
      return Right(car);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getMyCars() async {
    try {
      final cars = await remoteDataSource.getMyCars();
      return Right(cars);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(String carId) async {
    try {
      await remoteDataSource.deleteCar(carId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCarStatus(String carId, String status) async {
    try {
      await remoteDataSource.updateCarStatus(carId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
