import '../../../auth/domain/entities/user_entity.dart';
import '../../../booking/domain/entities/booking.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateUserInfo(String userId, String name, String phone);
  Future<void> deleteUser(String userId);
  Future<void> changeUserRole(String userId, String role);
  Future<List<Booking>> getAllBookings();
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status);
  Future<List<Map<String, dynamic>>> getPendingCars();
  Future<void> approveCar(String carId, bool isApproved);
}
