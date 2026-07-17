import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../presentation/bloc/booking_bloc.dart';
import '../../presentation/bloc/booking_state.dart';
import '../../../car_browsing/domain/entities/car.dart';
import '../../../car_browsing/presentation/bloc/car_bloc.dart';
import '../../../car_browsing/presentation/bloc/car_event.dart';
import 'booking_history_page.dart';
import 'vnpay_simulation_page.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class BookingPage extends StatefulWidget {
  final Car car;

  const BookingPage({super.key, required this.car});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTimeRange? _selectedDateRange;

  TimeOfDay _pickupTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _dropoffTime = const TimeOfDay(hour: 20, minute: 0);

  final TextEditingController _noteController = TextEditingController();

  bool _addBabySeat = false;
  bool _addGPS = false;
  bool _addInsurance = false;

  int _deliveryMethod = 0;

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

  Future<void> _selectTime(bool isPickup) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isPickup ? _pickupTime : _dropoffTime,
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupTime = picked;
        } else {
          _dropoffTime = picked;
        }
      });
    }
  }

  double _calculateTotal() {
    double total = 0;

    if (_selectedDateRange != null) {
      final days = _selectedDateRange!.duration.inDays + 1;
      total += days * widget.car.pricePerDay;
      if (_addBabySeat) total += (days * 2.0);
      if (_addInsurance) total += (days * 5.0);
    }

    if (_addGPS) total += 10.0;

    if (_deliveryMethod == 1) total += 15.0;

    return total;
  }

  void _showPriceBreakdown() {
    if (_selectedDateRange == null) return;

    final days = _selectedDateRange!.duration.inDays + 1;
    final basePrice = days * widget.car.pricePerDay;
    final babySeatPrice = _addBabySeat ? (days * 2.0) : 0.0;
    final insurancePrice = _addInsurance ? (days * 5.0) : 0.0;
    final gpsPrice = _addGPS ? 10.0 : 0.0;
    final deliveryPrice = _deliveryMethod == 1 ? 15.0 : 0.0;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chi tiết thanh toán', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(height: 30),
                _buildBreakdownRow('Thuê xe ($days ngày)', basePrice),
                if (_addBabySeat) _buildBreakdownRow('Ghế an toàn trẻ em', babySeatPrice),
                if (_addInsurance) _buildBreakdownRow('Bảo hiểm thân vỏ', insurancePrice),
                if (_addGPS) _buildBreakdownRow('Thiết bị GPS', gpsPrice),
                if (_deliveryMethod == 1) _buildBreakdownRow('Giao xe tận nơi', deliveryPrice),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${_calculateTotal().toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
    );
  }

  Widget _buildBreakdownRow(String title, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Xác nhận đặt xe'),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            context.read<CarBloc>().add(const FetchCarsEvent());
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
                    subtitle: Text('${widget.car.brand} • \$${widget.car.pricePerDay.toStringAsFixed(2)}/ngày'),
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

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Nhận: ${_pickupTime.format(context)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.access_time, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Trả: ${_dropoffTime.format(context)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.access_time, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Ghi chú bổ sung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Nhập yêu cầu đặc biệt của bạn (nếu có)...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const Divider(height: 24),

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
                      CheckboxListTile(
                        title: const Text('Bảo hiểm chuyến đi (+\$5/ngày)'),
                        subtitle: const Text('An tâm hơn với bảo hiểm thân vỏ'),
                        value: _addInsurance,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) => setState(() => _addInsurance = value ?? false),
                      ),
                      const Divider(),

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
                    ],
                  ),
                ),

                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.blue, size: 22),
                          onPressed: _selectedDateRange == null ? null : _showPriceBreakdown,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

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
                              addBabySeat: _addBabySeat,
                              addGPS: _addGPS,
                              deliveryMethod: _deliveryMethod,
                              note: _noteController.text,
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
