import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'user_management_page.dart';
import 'system_car_approval_page.dart';
import 'system_car_management_page.dart';
import 'booking_management_page.dart';
import 'admin_revenue_page.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tính năng quản trị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage())),
                    child: const _StatCard(title: 'Người dùng', value: 'Quản lý', color: Colors.blue, icon: Icons.people),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementPage())),
                    child: const _StatCard(title: 'Đơn đặt xe', value: 'Quản lý', color: Colors.orange, icon: Icons.assignment),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemCarApprovalPage())),
                    child: const _StatCard(title: 'Duyệt xe', value: 'Chờ duyệt', color: Colors.green, icon: Icons.check_circle),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemCarManagementPage())),
                    child: const _StatCard(title: 'Quản lý xe', value: 'Hệ thống', color: Colors.purple, icon: Icons.directions_car),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Thống kê tổng quan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                int totalUsers = 0;
                int totalCars = 0;
                int newBookings = 0;
                String revenueStr = 'Quản lý';

                if (state is AdminDashboardLoaded) {
                  totalUsers = state.totalUsers;
                  totalCars = state.totalCars;
                  newBookings = state.newBookings;
                  revenueStr = '\$${state.monthlyRevenue.toStringAsFixed(2)}';
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _StatCard(title: 'Tổng người dùng', value: totalUsers.toString(), color: Colors.blue, icon: Icons.people),
                    _StatCard(title: 'Tổng xe', value: totalCars.toString(), color: Colors.green, icon: Icons.directions_car),
                    _StatCard(title: 'Đơn thuê mới', value: newBookings.toString(), color: Colors.orange, icon: Icons.shopping_cart),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRevenuePage())),
                      child: _StatCard(title: 'Doanh thu hệ thống', value: revenueStr, color: Colors.purple, icon: Icons.attach_money),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
