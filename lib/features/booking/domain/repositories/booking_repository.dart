<<<<<<< HEAD
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking(Booking booking);
  Future<Either<Failure, List<Booking>>> getMyBookings(String userId);
  Future<Either<Failure, List<Booking>>> getOwnerBookings(String ownerId);
  Future<Either<Failure, Booking>> updateBookingStatus(String bookingId, BookingStatus status);
}
=======
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking(Booking booking);
  Future<Either<Failure, List<Booking>>> getMyBookings(String userId);
  Future<Either<Failure, List<Booking>>> getOwnerBookings(String ownerId);
  Future<Either<Failure, Booking>> updateBookingStatus(String bookingId, BookingStatus status);
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
