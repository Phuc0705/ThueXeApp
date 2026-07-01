import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final Booking booking;
  const CreateBookingEvent(this.booking);

  @override
  List<Object> get props => [booking];
}

class GetMyBookingsEvent extends BookingEvent {
  final String userId;
  const GetMyBookingsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetOwnerBookingsEvent extends BookingEvent {
  final String ownerId;
  const GetOwnerBookingsEvent(this.ownerId);

  @override
  List<Object> get props => [ownerId];
}

class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final BookingStatus status;
  const UpdateBookingStatusEvent(this.bookingId, this.status);

  @override
  List<Object> get props => [bookingId, status];
}
