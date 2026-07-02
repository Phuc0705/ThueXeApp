import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetOwnerBookings implements UseCase<List<Booking>, String> {
  final BookingRepository repository;

  GetOwnerBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(String ownerId) async {
    return await repository.getOwnerBookings(ownerId);
  }
}
