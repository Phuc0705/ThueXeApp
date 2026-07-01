import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetMyBookings implements UseCase<List<Booking>, String> {
  final BookingRepository repository;

  GetMyBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(String params) async {
    return await repository.getMyBookings(params);
  }
}
