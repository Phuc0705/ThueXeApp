import '../../../auth/domain/entities/user_entity.dart';
import '../../../booking/domain/entities/booking.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity> updateUserInfo(String userId, String name, String phone, String idCard);
  Future<List<Booking>> getAllBookings();
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status);
}
