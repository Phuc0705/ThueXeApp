import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking extends Equatable {
  final String id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final BookingStatus status;
  final String ownerId;
  final bool addBabySeat;
  final bool addGPS;
  final int deliveryMethod;
  final String note;

  const Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    this.ownerId = '',
    this.addBabySeat = false,
    this.addGPS = false,
    this.deliveryMethod = 0,
    this.note = '',
  });

  @override
  List<Object?> get props => [id, carId, userId, startDate, endDate, totalAmount, status, ownerId, addBabySeat, addGPS, deliveryMethod, note];
}
