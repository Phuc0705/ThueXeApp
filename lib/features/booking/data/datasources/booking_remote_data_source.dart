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
        
    // Chú ý: Trạng thái xe sẽ được tự động cập nhật bởi Database Trigger trên Supabase (tránh lỗi RLS).
        
    return BookingModel.fromJson(response);
  }

  Future<List<BookingModel>> _autoCompleteBookings(List<dynamic> jsonList) async {
    final List<BookingModel> result = [];
    final now = DateTime.now();
    for (var json in jsonList) {
      var booking = BookingModel.fromJson(json);
      if (booking.status == BookingStatus.confirmed && booking.endDate.difference(now).isNegative) {
        booking = await updateBookingStatus(booking.id, BookingStatus.completed);
      }
      result.add(booking);
    }
    return result;
  }

  @override
  Future<List<BookingModel>> getMyBookings(String userId) async {
    final response = await supabase
        .from('bookings')
        .select()
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
        
    return _autoCompleteBookings(response as List);
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
        
    return _autoCompleteBookings(response as List);
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
        
    // Nhả xe sẽ được tự động xử lý bởi Database Trigger trên Supabase
        
    return BookingModel.fromJson(response);
  }
}
