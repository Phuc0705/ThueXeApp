import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/owner_repository.dart';

class UpdateCarStatus {
  final OwnerRepository repository;

  UpdateCarStatus(this.repository);

  Future<Either<Failure, void>> call(String carId, String status) async {
    return await repository.updateCarStatus(carId, status);
  }
}
