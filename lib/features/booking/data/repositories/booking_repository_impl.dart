<<<<<<< HEAD
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Booking>> createBooking(Booking booking) async {
    try {
      final model = BookingModel(
        id: booking.id,
        carId: booking.carId,
        userId: booking.userId,
        startDate: booking.startDate,
        endDate: booking.endDate,
        totalAmount: booking.totalAmount,
        status: booking.status,
        ownerId: booking.ownerId,
      );
      final result = await remoteDataSource.createBooking(model);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể tạo đơn đặt xe'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings(String userId) async {
    try {
      final result = await remoteDataSource.getMyBookings(userId);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể tải lịch sử thuê xe'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getOwnerBookings(String ownerId) async {
    try {
      final result = await remoteDataSource.getOwnerBookings(ownerId);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể tải danh sách đơn đặt xe'));
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      final result = await remoteDataSource.updateBookingStatus(bookingId, status);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể cập nhật trạng thái đơn hàng'));
    }
  }
}
=======
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Booking>> createBooking(Booking booking) async {
    try {
      final model = BookingModel(
        id: booking.id,
        carId: booking.carId,
        userId: booking.userId,
        startDate: booking.startDate,
        endDate: booking.endDate,
        totalAmount: booking.totalAmount,
        status: booking.status,
        ownerId: booking.ownerId,
      );
      final result = await remoteDataSource.createBooking(model);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể tạo đơn đặt xe'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings(String userId) async {
    try {
      final result = await remoteDataSource.getMyBookings(userId);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể tải lịch sử thuê xe'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getOwnerBookings(String ownerId) async {
    try {
      final result = await remoteDataSource.getOwnerBookings(ownerId);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể tải danh sách đơn đặt xe'));
    }
  }

  @override
  Future<Either<Failure, Booking>> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      final result = await remoteDataSource.updateBookingStatus(bookingId, status);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('Không thể cập nhật trạng thái đơn hàng'));
    }
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
