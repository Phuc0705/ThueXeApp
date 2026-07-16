import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/domain/entities/booking.dart';

abstract class AdminRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUserInfo(String userId, String name, String phone, String idCard);
  Future<void> deleteUser(String userId);
  Future<void> changeUserRole(String userId, String role);
  Future<List<BookingModel>> getAllBookings();
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status, {String? cancelReason});
  Future<List<Map<String, dynamic>>> getSystemCars();
  Future<void> approveCar(String carId, bool isApproved);
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
  Future<void> updateUserInfo(String userId, String name, String phone, String idCard) async {
    await supabase
        .from('profiles')
        .update({
          'full_name': name,
          'phone': phone,
          'id_card': idCard,
        })
        .eq('id', userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await supabase.from('profiles').delete().eq('id', userId);
  }

  @override
  Future<void> changeUserRole(String userId, String role) async {
    await supabase
        .from('profiles')
        .update({'role': role})
        .eq('id', userId);
  }

  @override
  Future<List<BookingModel>> getAllBookings() async {
    final response = await supabase
        .from('bookings')
        .select('*, cars(name, image_urls, profiles(full_name, phone)), profiles(full_name)')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => BookingModel.fromJson(json)).toList();
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status, {String? cancelReason}) async {
    String statusStr = 'pending';
    switch (status) {
      case BookingStatus.pending: statusStr = 'pending'; break;
      case BookingStatus.confirmed: statusStr = 'approved'; break;
      case BookingStatus.completed: statusStr = 'completed'; break;
      case BookingStatus.cancelled: statusStr = 'cancelled'; break;
    }

    final updateData = <String, dynamic>{'status': statusStr};
    if (status == BookingStatus.cancelled && cancelReason != null) {
      updateData['cancel_reason'] = cancelReason;
    }

    final response = await supabase
        .from('bookings')
        .update(updateData)
        .eq('id', bookingId)
        .select()
        .single();
        
    // Nhả xe nếu hoàn thành hoặc hủy
      if (statusStr == 'completed' || statusStr == 'cancelled') {
        final bookingResponse = await supabase.from('bookings').select('car_id').eq('id', bookingId).single();
        final carId = bookingResponse['car_id'];
        
        final nowStr = DateTime.now().toIso8601String().split('T')[0];
        final activeCheck = await supabase
            .from('bookings')
            .select('id')
            .eq('car_id', carId)
            .eq('status', 'approved')
            .gte('end_date', nowStr)
            .limit(1);
            
        if ((activeCheck as List).isEmpty) {
          await supabase.from('cars').update({'status': 'available'}).eq('id', carId);
        }
      }
    
    return BookingModel.fromJson(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getSystemCars() async {
    final response = await supabase
        .from('cars')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> approveCar(String carId, bool isApproved) async {
    final status = isApproved ? 'available' : 'rejected';
    await supabase.from('cars').update({'status': status}).eq('id', carId).select().single();
  }
}
