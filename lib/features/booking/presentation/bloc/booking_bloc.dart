import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../../domain/usecases/get_owner_bookings.dart';
import '../../domain/usecases/update_booking_status.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBooking createBooking;
  final GetMyBookings getMyBookings;
  final GetOwnerBookings getOwnerBookings;
  final UpdateBookingStatus updateBookingStatus;

  BookingBloc({
    required this.createBooking,
    required this.getMyBookings,
    required this.getOwnerBookings,
    required this.updateBookingStatus,
  }) : super(BookingInitial()) {
    on<CreateBookingEvent>((event, emit) async {
      emit(BookingLoading());
      final result = await createBooking(event.booking);
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (booking) => emit(BookingSuccess(booking)),
      );
    });

    on<GetMyBookingsEvent>((event, emit) async {
      emit(BookingLoading());
      final result = await getMyBookings(event.userId);
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (bookings) => emit(MyBookingsLoaded(bookings)),
      );
    });

    on<GetOwnerBookingsEvent>((event, emit) async {
      emit(BookingLoading());
      final result = await getOwnerBookings(event.ownerId);
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (bookings) => emit(OwnerBookingsLoaded(bookings)),
      );
    });

    on<UpdateBookingStatusEvent>((event, emit) async {
      emit(BookingLoading());
      final result = await updateBookingStatus(UpdateBookingStatusParams(
        bookingId: event.bookingId,
        status: event.status,
      ));
      
      result.fold(
        (failure) => emit(BookingError(failure.message)),
        (_) {
          // Sau khi update, cần dispatch event để lấy lại danh sách mới
          // Gọi event lấy danh sách owner booking, tuy nhiên ta cần biết ownerId.
          // Để dễ dàng, ta chỉ cần emit trạng thái success (nếu muốn) hoặc add trực tiếp GetOwnerBookingsEvent.
          // Nhưng ta không lưu ownerId. Giải pháp nhanh: emit BookingSuccessUpdate (hoặc tự định nghĩa).
          // Tạm thời emit một state giả hoặc BookingInitial, và cho ManageBookingsPage tự reload.
          emit(BookingInitial()); 
        },
      );
    });
  }
}
