import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../car_browsing/domain/entities/car.dart';
import '../repositories/owner_repository.dart';

class GetMyCars {
  final OwnerRepository repository;

  GetMyCars(this.repository);

  Future<Either<Failure, List<Car>>> call() {
    return repository.getMyCars();
  }
}
