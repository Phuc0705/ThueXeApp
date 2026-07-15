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
  Future<void> updateUserInfo(String userId, String name, String phone) async {
    await remoteDataSource.updateUserInfo(userId, name, phone);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await remoteDataSource.deleteUser(userId);
  }

  @override
  Future<void> changeUserRole(String userId, String role) async {
    await remoteDataSource.changeUserRole(userId, role);
  }

  @override
  Future<List<BookingModel>> getAllBookings() {
    return remoteDataSource.getAllBookings();
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status) {
    return remoteDataSource.updateBookingStatus(bookingId, status);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingCars() {
    return remoteDataSource.getPendingCars();
  }

  @override
  Future<void> approveCar(String carId, bool isApproved) {
    return remoteDataSource.approveCar(carId, isApproved);
  }
}
