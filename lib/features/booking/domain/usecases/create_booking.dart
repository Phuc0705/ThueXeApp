<<<<<<< HEAD
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
=======
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
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
