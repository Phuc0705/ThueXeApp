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



  void _showCancelReasonDialog(Booking booking) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Lý do hủy đơn'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Nhập lý do hủy...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bỏ qua')),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do hủy')));
                  return;
                }
                context.read<AdminBloc>().add(UpdateBookingStatusEvent(booking.id, BookingStatus.cancelled, cancelReason: reasonController.text.trim()));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
            ),
          ],
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
            // Lọc ra các đơn hàng đã được thuê (hoặc các trạng thái khác ngoại trừ pending)
            // Vì yêu cầu: "chỉ hiện xe đã được thuê trên trang quản lý đơn đặt xe của admin"
            final filteredBookings = bookings.where((b) => b.status != BookingStatus.pending).toList();

            // Sắp xếp: Đang thuê (confirmed) lên đầu, hoàn thành/hủy xuống dưới
            // Với cùng trạng thái, sắp xếp theo thời gian kết thúc lâu nhất trên cùng (giảm dần)
            filteredBookings.sort((a, b) {
              int getStatusWeight(BookingStatus status) {
                if (status == BookingStatus.confirmed) return 0;
                if (status == BookingStatus.completed) return 1;
                return 2; // cancelled
              }
              
              int weightCompare = getStatusWeight(a.status).compareTo(getStatusWeight(b.status));
              if (weightCompare != 0) return weightCompare;
              
              // Nếu cùng trạng thái, endDate lớn hơn (lâu nhất) lên trước
              return b.endDate.compareTo(a.endDate);
            });

            if (filteredBookings.isEmpty) return const Center(child: Text('Không có đơn đặt xe nào.'));

            return ListView.builder(
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                final formatDate = DateFormat('dd/MM/yyyy');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (booking.carImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  booking.carImage!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 60),
                                ),
                              )
                            else
                              const Icon(Icons.directions_car, size: 60, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Mã đơn: ${booking.id.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      _buildStatusChip(booking.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(booking.carName ?? 'Xe ID: ${booking.carId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Khách thuê: ${booking.customerName ?? booking.userId}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text('Chủ xe: ${booking.ownerName ?? 'Không rõ'} - SĐT: ${booking.ownerPhone ?? 'Chưa cập nhật'}', style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Ngày thuê: ${formatDate.format(booking.startDate)} - ${formatDate.format(booking.endDate)}'),
                        if (booking.status == BookingStatus.confirmed) ...[
                          const SizedBox(height: 4),
                          Builder(builder: (_) {
                            final now = DateTime.now();
                            final remaining = booking.endDate.difference(now);
                            if (remaining.isNegative) {
                              return const Text('Trạng thái: Đã quá hạn, chờ hoàn thành', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold));
                            } else {
                              return Text('Thời gian còn lại: ${remaining.inDays} ngày ${remaining.inHours % 24} giờ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
                            }
                          }),
                        ],
                        if (booking.status == BookingStatus.cancelled && booking.cancelReason != null && booking.cancelReason!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Lý do hủy: ${booking.cancelReason}', style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng tiền: \$${booking.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            if (booking.status == BookingStatus.confirmed)
                              ElevatedButton(
                                onPressed: () => _showCancelReasonDialog(booking),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Hủy đơn', style: TextStyle(color: Colors.white)),
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
