import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to get owner bookings, we need a new event for this.
    // Wait, BookingEvent doesn't have GetOwnerBookingsEvent yet. Let's add it in the next step.
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<BookingBloc>().add(GetOwnerBookingsEvent(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn đặt xe')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingInitial) {
            // Refresh
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              context.read<BookingBloc>().add(GetOwnerBookingsEvent(authState.user.id));
            }
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OwnerBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(child: Text('Chưa có yêu cầu thuê xe nào.'));
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đơn hàng: #${booking.id.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                            _StatusBadge(status: booking.status),
                          ],
                        ),
                        const Divider(),
                        Text('Khách hàng ID: ${booking.userId.substring(0, 8)}...'),
                        Text('Thời gian: ${DateFormat('dd/MM/yyyy').format(booking.startDate)} - ${DateFormat('dd/MM/yyyy').format(booking.endDate)}'),
                        const SizedBox(height: 8),
                        Text('Tổng thu: \$${booking.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 16),
                        if (booking.status == BookingStatus.pending)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<BookingBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.cancelled));
                                  },
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Từ chối'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<BookingBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.confirmed));
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text('Phê duyệt'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is BookingError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Vui lòng chờ...'));
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case BookingStatus.pending: color = Colors.orange; text = 'Chờ duyệt'; break;
      case BookingStatus.confirmed: color = Colors.blue; text = 'Đã duyệt'; break;
      case BookingStatus.completed: color = Colors.green; text = 'Hoàn thành'; break;
      case BookingStatus.cancelled: color = Colors.red; text = 'Đã hủy'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
