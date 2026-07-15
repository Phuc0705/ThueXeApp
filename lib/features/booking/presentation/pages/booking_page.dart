import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/booking.dart';
import '../../presentation/bloc/booking_bloc.dart';
import '../../presentation/bloc/booking_event.dart';
import '../../presentation/bloc/booking_state.dart';
import '../../../car_browsing/domain/entities/car.dart';
import '../../../car_browsing/presentation/bloc/car_bloc.dart';
import '../../../car_browsing/presentation/bloc/car_event.dart';
import 'booking_history_page.dart';
import 'vnpay_simulation_page.dart';

class BookingPage extends StatefulWidget {
  final Car car;

  const BookingPage({super.key, required this.car});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTimeRange? _selectedDateRange;

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  double _calculateTotal() {
    if (_selectedDateRange == null) return 0;
    final days = _selectedDateRange!.duration.inDays + 1;
    return days * widget.car.pricePerDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt xe')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            // Trigger refresh cho CarBloc để đồng bộ trạng thái xe
            context.read<CarBloc>().add(FetchCarsEvent());
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đặt xe thành công!')),
            );
            // Sau khi đặt thành công, chuyển hướng người dùng đến trang Lịch sử
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(widget.car.name),
                    subtitle: Text('${widget.car.brand} • \$${widget.car.pricePerDay.toStringAsFixed(0)}/ngày'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Chọn thời gian thuê', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateRange == null
                              ? 'Chọn ngày nhận & trả xe'
                              : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontSize: 18)),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedDateRange != null && state is! BookingLoading)
                        ? () {
                            if (authState is Authenticated) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VNPaySimulationPage(
                                    carId: widget.car.id,
                                    userId: authState.user.id,
                                    ownerId: widget.car.ownerId,
                                    startDate: _selectedDateRange!.start,
                                    endDate: _selectedDateRange!.end,
                                    totalAmount: _calculateTotal(),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng đăng nhập để đặt xe')),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: state is BookingLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('XÁC NHẬN ĐẶT XE'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
