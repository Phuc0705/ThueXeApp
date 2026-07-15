import 'package:equatable/equatable.dart';
import '../../../booking/domain/entities/booking.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object> get props => [];
}

class FetchDashboardStats extends AdminEvent {}

class FetchAllUsers extends AdminEvent {}

class UpdateUserInfo extends AdminEvent {
  final String userId;
  final String name;
  final String phone;
  final String idCard;

  const UpdateUserInfo(this.userId, this.name, this.phone, this.idCard);

  @override
  List<Object> get props => [userId, name, phone, idCard];
}

class FetchAllBookings extends AdminEvent {}

class UpdateBookingStatusEvent extends AdminEvent {
  final String bookingId;
  final BookingStatus status;

  const UpdateBookingStatusEvent(this.bookingId, this.status);

  @override
  List<Object> get props => [bookingId, status];
}
