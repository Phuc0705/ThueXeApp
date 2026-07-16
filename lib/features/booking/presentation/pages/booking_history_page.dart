import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../domain/entities/booking.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<BookingBloc>().add(GetMyBookingsEvent(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Lịch sử thuê xe'),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is BookingInitial) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hủy đơn thành công!'), backgroundColor: Colors.green));
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              context.read<BookingBloc>().add(GetMyBookingsEvent(authState.user.id));
            }
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(child: Text('Bạn chưa có đơn đặt xe nào.'));
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                final displayId = booking.id.length > 8 
                    ? '${booking.id.substring(0, 8)}...' 
                    : booking.id;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mã đơn: #$displayId', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            _StatusBadge(status: booking.status),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(booking.startDate)} - ${DateFormat('dd/MM/yyyy').format(booking.endDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng thanh toán:', style: TextStyle(color: Colors.grey)),
                            Text(
                              '\$${booking.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.blue
                              ),
                            ),
                          ],
                        ),
                        if (booking.status == BookingStatus.pending) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<BookingBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.cancelled));
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Hủy đơn đặt xe'),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is BookingError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Vui lòng đăng nhập để xem lịch sử.'));
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
      case BookingStatus.confirmed: color = Colors.blue; text = 'Đã xác nhận'; break;
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
