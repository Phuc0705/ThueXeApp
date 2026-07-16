import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../car_browsing/domain/entities/car.dart';
import '../bloc/owner_bloc.dart';
import '../bloc/owner_event.dart';
import '../bloc/owner_state.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class OwnerRevenuePage extends StatefulWidget {
  const OwnerRevenuePage({super.key});

  @override
  State<OwnerRevenuePage> createState() => _OwnerRevenuePageState();
}

class _OwnerRevenuePageState extends State<OwnerRevenuePage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<BookingBloc>().add(GetOwnerBookingsEvent(authState.user.id));
      context.read<OwnerBloc>().add(GetMyCarsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Thống kê doanh thu'),
      body: BlocBuilder<OwnerBloc, OwnerState>(
        builder: (context, ownerState) {
          return BlocBuilder<BookingBloc, BookingState>(
            builder: (context, bookingState) {
              if (bookingState is BookingLoading || ownerState is OwnerLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bookingState is OwnerBookingsLoaded && ownerState is OwnerCarsLoaded) {
                final completedBookings = bookingState.bookings.where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.confirmed).toList();
                
                double totalRevenue = 0;
                final Map<String, double> carRevenueMap = {};
                
                for (var booking in completedBookings) {
                  final days = booking.endDate.difference(booking.startDate).inDays + 1;
                  final extraFees = (booking.addBabySeat ? 2.0 * days : 0) + (booking.addGPS ? 10.0 : 0) + (booking.deliveryMethod == 1 ? 15.0 : 0);
                  final baseRent = booking.totalAmount - extraFees;
                  
                  final revenue = baseRent * 0.90; // 90% tiền thuê gốc cho chủ xe
                  totalRevenue += revenue;
                  
                  carRevenueMap[booking.carId] = (carRevenueMap[booking.carId] ?? 0) + revenue;
                }

                if (completedBookings.isEmpty) {
                  return const Center(child: Text('Chưa có doanh thu nào được ghi nhận.'));
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
                            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
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
                              'Tổng Doanh Thu',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Đã trừ 10% phí nền tảng',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Chi tiết doanh thu theo xe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...carRevenueMap.entries.map((entry) {
                        Car? foundCar;
                        try {
                          foundCar = ownerState.cars.firstWhere((c) => c.id == entry.key);
                        } catch (_) {}
                        final car = foundCar ?? ownerState.cars.first;
                        
                        final revenue = entry.value;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: car.imageUrl.isNotEmpty 
                                    ? DecorationImage(image: NetworkImage(car.imageUrl), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: car.imageUrl.isEmpty ? const Icon(Icons.directions_car, color: Colors.blue) : null,
                            ),
                            title: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(car.type),
                            trailing: Text(
                              '+\$${revenue.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }

              if (bookingState is BookingError) {
                return Center(child: Text(bookingState.message));
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
