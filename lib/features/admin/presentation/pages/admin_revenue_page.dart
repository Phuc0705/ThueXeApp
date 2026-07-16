import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../booking/domain/entities/booking.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class AdminRevenuePage extends StatefulWidget {
  const AdminRevenuePage({super.key});

  @override
  State<AdminRevenuePage> createState() => _AdminRevenuePageState();
}

class _AdminRevenuePageState extends State<AdminRevenuePage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchAdminRevenue());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Doanh thu hệ thống'),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminError) {
            return Center(child: Text(state.message));
          }
          if (state is AdminRevenueLoaded) {
            final completedBookings = state.bookings.where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.confirmed).toList();
            
            double totalAppRevenue = 0;
            final Map<String, Map<String, double>> ownerSalesMap = {};
            
            for (var booking in completedBookings) {
              final days = booking.endDate.difference(booking.startDate).inDays + 1;
              final extraFees = (booking.addBabySeat ? 2.0 * days : 0) + (booking.addGPS ? 10.0 : 0) + (booking.deliveryMethod == 1 ? 15.0 : 0);
              final baseRent = booking.totalAmount - extraFees;
              
              final appCommission = (baseRent * 0.10) + extraFees;
              final ownerPayout = baseRent * 0.90;
              
              totalAppRevenue += appCommission;
              
              if (!ownerSalesMap.containsKey(booking.ownerId)) {
                ownerSalesMap[booking.ownerId] = {'totalSales': 0, 'appCommission': 0, 'ownerPayout': 0};
              }
              ownerSalesMap[booking.ownerId]!['totalSales'] = ownerSalesMap[booking.ownerId]!['totalSales']! + booking.totalAmount;
              ownerSalesMap[booking.ownerId]!['appCommission'] = ownerSalesMap[booking.ownerId]!['appCommission']! + appCommission;
              ownerSalesMap[booking.ownerId]!['ownerPayout'] = ownerSalesMap[booking.ownerId]!['ownerPayout']! + ownerPayout;
            }

            if (completedBookings.isEmpty) {
              return const Center(child: Text('Chưa có doanh thu nào được ghi nhận trên hệ thống.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Tổng Doanh Thu (Hoa hồng 10% + Phụ phí)',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalAppRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Chi tiết doanh thu theo Chủ xe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ...ownerSalesMap.entries.map((entry) {
                    final ownerId = entry.key;
                    final totalSales = entry.value['totalSales']!;
                    final appCommission = entry.value['appCommission']!;
                    final ownerPayout = entry.value['ownerPayout']!;
                    
                    UserEntity? foundUser;
                    try {
                      foundUser = state.users.firstWhere((u) => u.id == ownerId);
                    } catch (_) {}
                    final ownerUser = foundUser ?? state.users.first;
                    
                    final ownerName = ownerUser.id == ownerId ? ownerUser.fullName : 'Chủ xe ẩn danh ($ownerId)';
                    final ownerEmail = ownerUser.id == ownerId ? ownerUser.email : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: const Icon(Icons.person, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      if (ownerEmail.isNotEmpty)
                                        Text(ownerEmail, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Tổng GD', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('\$${totalSales.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Doanh thu Chủ xe (Tiền thuê 90%)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('\$${ownerPayout.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Doanh thu Admin (10% + Phụ phí)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('\$${appCommission.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
