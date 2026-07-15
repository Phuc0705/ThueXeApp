import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/domain/entities/booking.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getDashboardStats() {
    return remoteDataSource.getDashboardStats();
  }

  @override
  Future<List<UserModel>> getAllUsers() {
    return remoteDataSource.getAllUsers();
  }

  @override
  Future<UserModel> updateUserInfo(String userId, String name, String phone, String idCard) {
    return remoteDataSource.updateUserInfo(userId, name, phone, idCard);
  }

  @override
  Future<List<BookingModel>> getAllBookings() {
    return remoteDataSource.getAllBookings();
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status) {
    return remoteDataSource.updateBookingStatus(bookingId, status);
  }
}
