import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../car_browsing/domain/entities/car.dart';

abstract class OwnerRepository {
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
  });

  Future<Either<Failure, List<Car>>> getMyCars();
  Future<Either<Failure, void>> deleteCar(String carId);
  Future<Either<Failure, void>> updateCarStatus(String carId, String status);
}
