<<<<<<< HEAD
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

  const Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    this.ownerId = '',
  });

  @override
  List<Object?> get props => [id, carId, userId, startDate, endDate, totalAmount, status, ownerId];
}
=======
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

  const Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    this.ownerId = '',
  });

  @override
  List<Object?> get props => [id, carId, userId, startDate, endDate, totalAmount, status, ownerId];
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
