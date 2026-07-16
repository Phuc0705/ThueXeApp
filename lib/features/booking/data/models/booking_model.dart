import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.carId,
    required super.userId,
    required super.startDate,
    required super.endDate,
    required super.totalAmount,
    required super.status,
    super.ownerId,
    super.addBabySeat,
    super.addGPS,
    super.deliveryMethod,
    super.note,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      carId: json['car_id'] ?? json['carId'],
      userId: json['customer_id'] ?? json['userId'], // Lấy từ customer_id thay vì user_id
      ownerId: json['owner_id'] ?? json['ownerId'] ?? '', // Vẫn giữ phòng trường hợp dùng sau này
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
      totalAmount: (json['total_amount'] ?? json['totalAmount'] ?? 0).toDouble(),
      addBabySeat: json['add_baby_seat'] ?? false,
      addGPS: json['add_gps'] ?? false,
      deliveryMethod: json['delivery_method'] ?? 0,
      note: json['note'] ?? '',
      status: () {
        switch (json['status']) {
          case 'pending': return BookingStatus.pending;
          case 'approved': return BookingStatus.confirmed;
          case 'completed': return BookingStatus.completed;
          case 'cancelled': 
          case 'rejected': return BookingStatus.cancelled;
          default: return BookingStatus.pending;
        }
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'car_id': carId,
      'customer_id': userId, // In SQL it is customer_id
      // 'owner_id': ownerId, // We don't save owner_id to bookings table, it's inferred from cars table
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'total_amount': totalAmount,
      'add_baby_seat': addBabySeat,
      'add_gps': addGPS,
      'delivery_method': deliveryMethod,
      'note': note,
      'status': () {
        switch (status) {
          case BookingStatus.pending: return 'pending';
          case BookingStatus.confirmed: return 'approved';
          case BookingStatus.completed: return 'completed';
          case BookingStatus.cancelled: return 'cancelled';
        }
      }(),
    };
  }
}
