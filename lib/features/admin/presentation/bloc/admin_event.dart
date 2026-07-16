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

class DeleteUserEvent extends AdminEvent {
  final String userId;
  const DeleteUserEvent(this.userId);
  @override
  List<Object> get props => [userId];
}

class ChangeUserRoleEvent extends AdminEvent {
  final String userId;
  final String role;
  const ChangeUserRoleEvent(this.userId, this.role);
  @override
  List<Object> get props => [userId, role];
}

class FetchAllBookings extends AdminEvent {}

class UpdateBookingStatusEvent extends AdminEvent {
  final String bookingId;
  final BookingStatus status;
  final String? cancelReason;

  const UpdateBookingStatusEvent(this.bookingId, this.status, {this.cancelReason});

  @override
  List<Object> get props => [bookingId, status, if (cancelReason != null) cancelReason!];
}

class FetchSystemCars extends AdminEvent {}

class ApproveCarEvent extends AdminEvent {
  final String carId;
  final bool isApproved;

  const ApproveCarEvent(this.carId, this.isApproved);

  @override
  List<Object> get props => [carId, isApproved];
}

class FetchAdminRevenue extends AdminEvent {}
