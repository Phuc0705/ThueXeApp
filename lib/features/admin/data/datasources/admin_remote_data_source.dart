import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/domain/entities/booking.dart';

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> updateUserInfo(String userId, String name, String phone, String idCard);
  Future<List<BookingModel>> getAllBookings();
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabase;

  AdminRemoteDataSourceImpl(this.supabase);

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersResponse = await supabase.from('profiles').select('id');
    final carsResponse = await supabase.from('cars').select('id');
    final bookingsResponse = await supabase.from('bookings').select('id, total_amount, status, created_at');

    final bookings = bookingsResponse as List;
    
    final now = DateTime.now();
    int newBookingsCount = 0;
    double monthlyRevenue = 0;

    for (var b in bookings) {
      final createdAt = DateTime.parse(b['created_at']);
      if (createdAt.year == now.year && createdAt.month == now.month) {
        newBookingsCount++;
      }
      
      if (b['status'] == 'completed') {
        monthlyRevenue += (b['total_amount'] ?? 0).toDouble();
      }
    }

    return {
      'totalUsers': (usersResponse as List).length,
      'totalCars': (carsResponse as List).length,
      'newBookings': newBookingsCount,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await supabase.from('profiles').select().order('created_at', ascending: false);
    return (response as List).map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<UserModel> updateUserInfo(String userId, String name, String phone, String idCard) async {
    final response = await supabase
        .from('profiles')
        .update({
          'full_name': name,
          'phone': phone,
          'id_card': idCard,
        })
        .eq('id', userId)
        .select()
        .single();
    return UserModel.fromJson(response);
  }

  @override
  Future<List<BookingModel>> getAllBookings() async {
    final response = await supabase
        .from('bookings')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => BookingModel.fromJson(json)).toList();
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status) async {
    String statusStr = 'pending';
    switch (status) {
      case BookingStatus.pending: statusStr = 'pending'; break;
      case BookingStatus.confirmed: statusStr = 'approved'; break;
      case BookingStatus.completed: statusStr = 'completed'; break;
      case BookingStatus.cancelled: statusStr = 'cancelled'; break;
    }

    final response = await supabase
        .from('bookings')
        .update({'status': statusStr})
        .eq('id', bookingId)
        .select()
        .single();
    
    return BookingModel.fromJson(response);
  }
}
