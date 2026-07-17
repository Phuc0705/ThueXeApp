import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../booking/domain/entities/booking.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

import '../../../../core/widgets/gradient_app_bar.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchAllBookings());
  }

  void _showStatusDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Cập nhật trạng thái đơn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Đã duyệt'),
                onTap: () {
                  context.read<AdminBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.confirmed));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Hoàn thành'),
                onTap: () {
                  context.read<AdminBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.completed));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Hủy đơn'),
                onTap: () {
                  context.read<AdminBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.cancelled));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Quản lý đơn đặt xe',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdminBloc>().add(FetchAllBookings());
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.red))));
          }
        },
        buildWhen: (previous, current) => current is AdminBookingsLoaded || current is AdminLoading || current is AdminError,
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminBookingsLoaded) {
            final bookings = state.bookings;
            if (bookings.isEmpty) return const Center(child: Text('Không có đơn đặt xe nào.'));

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final formatDate = DateFormat('dd/MM/yyyy');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mã đơn: ${booking.id.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                            _buildStatusChip(booking.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Khách hàng ID: ${booking.userId}'),
                        Text('Xe ID: ${booking.carId}'),
                        const SizedBox(height: 8),
                        Text('Ngày thuê: ${formatDate.format(booking.startDate)} - ${formatDate.format(booking.endDate)}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng tiền: \$${booking.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            ElevatedButton(
                              onPressed: () => _showStatusDialog(booking),
                              child: const Text('Cập nhật'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        text = 'Chờ duyệt';
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        text = 'Đã duyệt';
        break;
      case BookingStatus.completed:
        color = Colors.green;
        text = 'Hoàn thành';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'Đã hủy';
        break;
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }
}
