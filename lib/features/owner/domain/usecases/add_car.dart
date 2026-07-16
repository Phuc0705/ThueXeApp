import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../car_browsing/domain/entities/car.dart';
import '../repositories/owner_repository.dart';

class AddCarParams {
  final String name;
  final String brand;
  final double pricePerDay;
  final String type;
  final String fuelType;
  final String transmission;
  final String location;
  final String description;
  final int seats;
  final XFile carImage;
  final XFile docFrontImage;
  final XFile docBackImage;

  AddCarParams({
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.type,
    required this.fuelType,
    required this.transmission,
    required this.location,
    required this.description,
    required this.seats,
    required this.carImage,
    required this.docFrontImage,
    required this.docBackImage,
  });
}

class AddCar {
  final OwnerRepository repository;

  AddCar(this.repository);

  Future<Either<Failure, Car>> call(AddCarParams params) {
    return repository.addCar(
      name: params.name,
      brand: params.brand,
      pricePerDay: params.pricePerDay,
      type: params.type,
      fuelType: params.fuelType,
      transmission: params.transmission,
      location: params.location,
      description: params.description,
      seats: params.seats,
      carImage: params.carImage,
      docFrontImage: params.docFrontImage,
      docBackImage: params.docBackImage,
    );
  }
}
