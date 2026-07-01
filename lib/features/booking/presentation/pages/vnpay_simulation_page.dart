import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../../services/vietqr_service.dart';

class VNPaySimulationPage extends StatefulWidget {
  final String carId;
  final String userId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  
  // ⭐ Thông tin tài khoản nhận tiền (có thể lấy từ config)
  final String? bankCode;          // Mã ngân hàng (VD: 970012)
  final String? accountNumber;     // Số tài khoản
  final String? accountName;       // Tên tài khoản

  const VNPaySimulationPage({
    super.key,
    required this.carId,
    required this.userId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.bankCode,
    this.accountNumber,
    this.accountName,
  });

  @override
  State<VNPaySimulationPage> createState() => _VNPaySimulationPageState();
}

class _VNPaySimulationPageState extends State<VNPaySimulationPage> {
  bool _isProcessing = false;
  late String _qrData;
  late String _bookingId;
  late String _amountVND;

  @override
  void initState() {
    super.initState();
    // Tạo ID booking tạm thời
    _bookingId = 'BOOKING_${DateTime.now().millisecondsSinceEpoch}';
    
    // Convert $ to VND (1$ ≈ 25,000 VND)
    int amountVND = (widget.totalAmount * 25000).toInt();
    _amountVND = amountVND.toString();
    
    // Generate VietQR data
    _generateQRCode(amountVND);
  }

  void _generateQRCode(int amountVND) {
    // Sử dụng thông tin tài khoản mặc định hoặc từ config
    final bankCode = widget.bankCode ?? BankCodes.VIETCOMBANK;
    final accountNumber = widget.accountNumber ?? '1234567890'; // ⭐ Thay bằng số tài khoản thực
    final accountName = widget.accountName ?? 'ThueXeApp'; // ⭐ Thay bằng tên tài khoản

    // Generate VietQR theo định dạng EMV
    _qrData = VietQRService.generateVietQR(
      bankCode: bankCode,
      accountNumber: accountNumber,
      accountName: accountName,
      amount: amountVND,
      description: 'Dat xe tu ${DateFormat('dd/MM').format(widget.startDate)}',
      transactionId: _bookingId,
    );
  }

  void _processPayment(BuildContext context) {
    setState(() => _isProcessing = true);
    
    // Giả lập thời gian xử lý thanh toán của ngân hàng (2-3 giây)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VietQR'),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // ⭐ Card chứa QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // VietQR Logo / Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const Text(
                              'VIETQR',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Thanh toán bằng mã QR',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 24),

                      // ⭐ QR Code chính
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 280.0,
                          gapless: false,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          semanticsLabel: 'VietQR Payment Code',
                          errorBuilder: (context, error) {
                            return Container(
                              width: 280,
                              height: 280,
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  'QR Error\n${error.toString()}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Thông tin giao dịch
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Số tiền',
                              '$_amountVND ₫',
                              Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Mã giao dịch',
                              _bookingId,
                              Colors.grey[700],
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Thời gian thuê',
                              '${DateFormat('dd/MM/yyyy').format(widget.startDate)} - ${DateFormat('dd/MM/yyyy').format(widget.endDate)}',
                              Colors.grey[700],
                              fontSize: 12,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              'Số ngày',
                              '${widget.endDate.difference(widget.startDate).inDays + 1} ngày',
                              Colors.grey[700],
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ⭐ Nút thanh toán
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _processPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'ĐÃ THANH TOÁN THÀNH CÔNG',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ⭐ Hướng dẫn sử dụng
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber[800],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cách quét QR Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.amber[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '📱 Mở app ngân hàng:\n'
                        '   VietcomBank, MB Bank, Techcombank...\n\n'
                        '🔍 Chọn "Quét QR" hoặc "Thanh toán QR"\n\n'
                        '📷 Quét mã QR bên trên\n\n'
                        '✅ Xác nhận số tiền và OTP\n\n'
                        '🎉 Giao dịch hoàn tất!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị thông tin (label - value)
  Widget _buildInfoRow(
    String label,
    String value,
    Color? valueColor, {
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    String? fontFamily,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: valueColor ?? Colors.black87,
              fontFamily: fontFamily,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
