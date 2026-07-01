import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class UpdateBookingStatusParams extends Equatable {
  final String bookingId;
  final BookingStatus status;

  const UpdateBookingStatusParams({required this.bookingId, required this.status});

  @override
  List<Object> get props => [bookingId, status];
}

class UpdateBookingStatus implements UseCase<Booking, UpdateBookingStatusParams> {
  final BookingRepository repository;

  UpdateBookingStatus(this.repository);

  @override
  Future<Either<Failure, Booking>> call(UpdateBookingStatusParams params) async {
    return await repository.updateBookingStatus(params.bookingId, params.status);
  }
}
