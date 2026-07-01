import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final Booking booking;
  const BookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class MyBookingsLoaded extends BookingState {
  final List<Booking> bookings;
  const MyBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

class OwnerBookingsLoaded extends BookingState {
  final List<Booking> bookings;
  const OwnerBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
