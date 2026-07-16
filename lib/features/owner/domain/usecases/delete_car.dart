import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/owner_repository.dart';

class DeleteCar {
  final OwnerRepository repository;

  DeleteCar(this.repository);

  Future<Either<Failure, void>> call(String carId) async {
    return await repository.deleteCar(carId);
  }
}
