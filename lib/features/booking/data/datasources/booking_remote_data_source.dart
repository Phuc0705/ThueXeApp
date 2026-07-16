import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../../domain/entities/booking.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingModel booking);
  Future<List<BookingModel>> getMyBookings(String userId);
  Future<List<BookingModel>> getOwnerBookings(String ownerId);
  Future<BookingModel> updateBookingStatus(String bookingId, BookingStatus status, {String? cancelReason});
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final SupabaseClient supabase;

  BookingRemoteDataSourceImpl(this.supabase);

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final response = await supabase
        .from('bookings')
        .insert(booking.toJson())
        .select()
        .single();
        
    // Cập nhật trạng thái xe thành rented
    await supabase
        .from('cars')
        .update({'status': 'rented'})
        .eq('id', booking.carId);
        
    return BookingModel.fromJson(response);
  }

  @override
  Future<List<BookingModel>> getMyBookings(String userId) async {
    final response = await supabase
        .from('bookings')
        .select()
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
        
    return (response as List).map((json) => BookingModel.fromJson(json)).toList();
  }

  @override
  Future<List<BookingModel>> getOwnerBookings(String ownerId) async {
    // Tìm các xe của owner
    final carsResponse = await supabase
        .from('cars')
        .select('id')
        .eq('owner_id', ownerId);
        
    final carIds = (carsResponse as List).map((c) => c['id']).toList();
    
    if (carIds.isEmpty) return [];
    
    // Lấy bookings của các xe đó
    final response = await supabase
        .from('bookings')
        .select()
        .inFilter('car_id', carIds)
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
      final carId = response['car_id'];
      if (carId != null) {
        await supabase.from('cars').update({'status': 'available'}).eq('id', carId);
      }
    }
        
    return BookingModel.fromJson(response);
  }
}
