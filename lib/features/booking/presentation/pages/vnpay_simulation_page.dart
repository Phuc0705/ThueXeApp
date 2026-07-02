import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'package:thuexeproject/config/vietqr_config.dart';
import '../../../car_browsing/presentation/bloc/car_bloc.dart';
import '../../../car_browsing/presentation/bloc/car_event.dart';
// TODO: Đảm bảo import đúng đường dẫn của BookingHistoryPage
import 'booking_history_page.dart';

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
  late String _bookingId;
  late String _amountVND;

  @override
  void initState() {
    super.initState();
    _bookingId = 'BOOKING_${DateTime.now().millisecondsSinceEpoch}';
    int amountVND = (widget.totalAmount * VietQRConfig.usdToVndRate).toInt();
    _amountVND = NumberFormat('#,###', 'vi_VN').format(amountVND);
  }

  String get _vietQrUrl {
    int amount = (widget.totalAmount * VietQRConfig.usdToVndRate).toInt();
    final bank = VietQRConfig.bankCode;
    final accNum = VietQRConfig.accountNumber;
    final accName = Uri.encodeComponent(VietQRConfig.accountName);
    final desc = Uri.encodeComponent('Dat xe $_bookingId');

    return 'https://img.vietqr.io/image/$bank-$accNum-compact.png?amount=$amount&addInfo=$desc&accountName=$accName';
  }

  void _processPayment(BuildContext context) {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      context.read<BookingBloc>().add(
        CreateBookingEvent(
            Booking(
              id: '',
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

  // CẢI TIẾN: Cảnh báo người dùng khi họ bấm lùi lại (Hủy thanh toán)
  Future<bool> _onWillPop() async {
    if (_isProcessing) return false;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy giao dịch?'),
        content: const Text('Bạn chưa thanh toán. Xác nhận hủy đặt xe và quay lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tiếp tục thanh toán'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy bỏ'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // CẢI TIẾN: Bọc PopScope để chặn thao tác thoát trang ngẫu nhiên
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán VietQR'),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
        body: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanh toán và Đặt xe thành công!'), backgroundColor: Colors.green),
              );

              // Cập nhật lại danh sách xe để refresh trạng thái isAvailable
              context.read<CarBloc>().add(FetchCarsEvent());

              // CẢI TIẾN: Điều hướng chuẩn sang Lịch sử đặt xe
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
                    (route) => route.isFirst,
              );
            } else if (state is BookingError) {
              setState(() => _isProcessing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi đặt xe: ${state.message}'), backgroundColor: Colors.red),
              );
            }
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Card chứa QR Code (Giữ nguyên UI xịn xò của bạn)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, spreadRadius: 2)
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                children: [
                                  const Text('VIETQR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 2)),
                                  const SizedBox(height: 4),
                                  Text('Thanh toán bằng mã QR', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            const Divider(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: Colors.grey[300]!, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.network(
                                _vietQrUrl,
                                width: 280,
                                height: 280,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(width: 280, height: 280, child: Center(child: CircularProgressIndicator()));
                                },
                                errorBuilder: (context, error, stackTrace) => SizedBox(
                                  width: 280, height: 280,
                                  child: Center(child: Text('Không thể tải mã QR.\nVui lòng kiểm tra kết nối mạng.', textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700]))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Số tiền', '$_amountVND ₫', Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Người nhận', VietQRConfig.accountName, Colors.grey[700], fontSize: 12),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Mã giao dịch', _bookingId, Colors.grey[700], fontSize: 11, fontFamily: 'monospace'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Nút thanh toán
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () => _processPayment(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          // code là chức năng ỉa
                          child: _isProcessing
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('GIẢ LẬP THANH TOÁN XONG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Khóa màn hình chạm lung tung khi đang loading
              if (_isProcessing)
                Container(color: Colors.black.withOpacity(0.2), width: double.infinity, height: double.infinity),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor, {double fontSize = 12, FontWeight fontWeight = FontWeight.normal, String? fontFamily}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: valueColor ?? Colors.black87, fontFamily: fontFamily),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}