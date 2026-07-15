import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../booking/domain/entities/booking.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final int totalUsers;
  final int totalCars;
  final int newBookings;
  final double monthlyRevenue;

  const AdminDashboardLoaded({
    required this.totalUsers,
    required this.totalCars,
    required this.newBookings,
    required this.monthlyRevenue,
  });

  @override
  List<Object> get props => [totalUsers, totalCars, newBookings, monthlyRevenue];
}

class AdminUsersLoaded extends AdminState {
  final List<UserEntity> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

class AdminBookingsLoaded extends AdminState {
  final List<Booking> bookings;
  const AdminBookingsLoaded(this.bookings);
  @override
  List<Object> get props => [bookings];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object> get props => [message];
}
