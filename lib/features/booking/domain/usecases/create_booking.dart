import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBooking implements UseCase<Booking, Booking> {
  final BookingRepository repository;

  CreateBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(Booking params) async {
    return await repository.createBooking(params);
  }
}
