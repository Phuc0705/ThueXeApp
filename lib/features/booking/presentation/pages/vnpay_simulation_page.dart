import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class VNPaySimulationPage extends StatefulWidget {
  final String carId;
  final String userId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;

  const VNPaySimulationPage({
    super.key,
    required this.carId,
    required this.userId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
  });

  @override
  State<VNPaySimulationPage> createState() => _VNPaySimulationPageState();
}

class _VNPaySimulationPageState extends State<VNPaySimulationPage> {
  bool _isProcessing = false;

  // Tạo URL thanh toán VNPay với thông tin booking
  String _generateVNPayURL() {
    final bookingId = DateTime.now().millisecondsSinceEpoch.toString();
    final amount = (widget.totalAmount * 100).toInt(); // VNPay yêu cầu tính bằng đơn vị nhỏ nhất
    
    // Định dạng URL VNPay (thay YOUR_MERCHANT_CODE bằng mã thực tế)
    final vnpayUrl = 
      'vnpay_payment_${bookingId}_${widget.userId}_${amount}_${widget.carId}';
    
    return vnpayUrl;
  }

  void _processPayment(BuildContext context) {
    setState(() => _isProcessing = true);
    
    // Giả lập thời gian xử lý thanh toán của ngân hàng
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      // Gọi Bloc để tạo đơn hàng mới trên Supabase
      context.read<BookingBloc>().add(
        CreateBookingEvent(
          Booking(
            id: '', // Sẽ do Supabase tự generate
            carId: widget.carId,
            userId: widget.userId,
            ownerId: widget.ownerId,
            startDate: widget.startDate,
            endDate: widget.endDate,
            totalAmount: widget.totalAmount,
            status: BookingStatus.pending,
          )
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _generateVNPayURL();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán và Đặt xe thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            // Quay về 2 trang trước (Booking -> CarDetail)
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is BookingError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi đặt xe: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    // Logo VNPay
                    Image.network(
                      'https://vnpay.vn/s1/statics.vnpay.vn/2023/9/06ncktiwd6dc1694418196384.png',
                      height: 50,
                      errorBuilder: (_, __, ___) => const Text(
                        'VNPAY',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Hướng dẫn
                    const Text(
                      'Quét mã QR để thanh toán',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    
                    // QR Code thực tế
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[900]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImage(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Hiển thị số tiền
                    Text(
                      'Số tiền: \$${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Hiển thị thông tin booking
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Xe ID:', widget.carId),
                          _buildInfoRow('User ID:', widget.userId),
                          _buildInfoRow(
                            'Ngày bắt đầu:',
                            '${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}',
                          ),
                          _buildInfoRow(
                            'Ngày kết thúc:',
                            '${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Nút thanh toán
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isProcessing ? null : () => _processPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GIẢ LẬP THANH TOÁN THÀNH CÔNG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget để hiển thị thông tin
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
