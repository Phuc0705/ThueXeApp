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

  // 1. Phụ kiện
  bool _addBabySeat = false;
  bool _addGPS = false;
  // 2. Hình thức nhận xe (0: Tự lấy, 1: Giao tận nơi)
  int _deliveryMethod = 0;
  // 3. Thuê tài xế
  bool _withDriver = false;
  // 4. Điều khoản
  bool _isAgreedToTerms = false;

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
    double total = days * widget.car.pricePerDay;

    // Phụ kiện & Dịch vụ đi kèm
    if (_addBabySeat) total += (days * 2.0); // 2$/ngày
    if (_addGPS) total += 10.0; // 10$ trọn gói

    // Hình thức nhận xe
    if (_deliveryMethod == 1) total += 15.0; // Phí giao xe 15$

    // Thuê tài xế
    if (_withDriver) total += (days * 30.0); // 30$/ngày

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt xe')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            context.read<CarBloc>().add(FetchCarsEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đặt xe thành công!'), backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                const SizedBox(height: 16),
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
                          style: TextStyle(
                            color: _selectedDateRange == null ? Colors.grey[600] : Colors.black,
                            fontWeight: _selectedDateRange == null ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sử dụng Expanded ListView để không bị tràn màn hình khi có nhiều lựa chọn
                Expanded(
                  child: ListView(
                    children: [
                      // Tính năng 1: Phụ kiện
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Phụ kiện & Dịch vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      CheckboxListTile(
                        title: const Text('Ghế an toàn cho trẻ em (+\$2/ngày)'),
                        value: _addBabySeat,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) => setState(() => _addBabySeat = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Thiết bị dẫn đường GPS (+\$10/chuyến)'),
                        value: _addGPS,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) => setState(() => _addGPS = value ?? false),
                      ),
                      const Divider(),

                      // Tính năng 2: Hình thức nhận xe
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Hình thức nhận xe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      RadioListTile<int>(
                        title: const Text('Tự đến bãi lấy xe (Miễn phí)'),
                        value: 0,
                        groupValue: _deliveryMethod,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (int? value) => setState(() => _deliveryMethod = value!),
                      ),
                      RadioListTile<int>(
                        title: const Text('Giao xe tận nơi (+\$15)'),
                        value: 1,
                        groupValue: _deliveryMethod,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (int? value) => setState(() => _deliveryMethod = value!),
                      ),
                      const Divider(),

                      // Tính năng 3: Thuê tài xế
                      SwitchListTile(
                        title: const Text('Thuê tài xế riêng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: const Text('Thư giãn tận hưởng chuyến đi (+\$30/ngày)'),
                        value: _withDriver,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.blue,
                        onChanged: (bool value) => setState(() => _withDriver = value),
                      ),
                    ],
                  ),
                ),

                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tính năng 4: Đồng ý điều khoản
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreedToTerms,
                      onChanged: (bool? value) => setState(() => _isAgreedToTerms = value ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'Tôi đồng ý với các điều khoản và chính sách thuê xe.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedDateRange != null && _isAgreedToTerms && state is! BookingLoading)
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
                          const SnackBar(content: Text('Vui lòng đăng nhập trước khi đặt xe!')),
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
                        : const Text('XÁC NHẬN ĐẶT XE', style: TextStyle(fontWeight: FontWeight.bold)),
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
