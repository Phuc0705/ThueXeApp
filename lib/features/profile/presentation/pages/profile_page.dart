import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../booking/presentation/pages/booking_history_page.dart';
import '../../../owner/presentation/pages/add_car_page.dart';
import '../../../owner/presentation/pages/my_cars_page.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../admin/presentation/pages/user_management_page.dart';
import '../../../admin/presentation/pages/system_car_approval_page.dart';
import 'edit_profile_page.dart';

import '../../../../core/widgets/gradient_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Hồ sơ của tôi'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user.email, style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 32),
                  
                  _ProfileMenuTile(
                    icon: Icons.edit,
                    title: 'Chỉnh sửa thông tin cá nhân',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    },
                  ),
                  const SizedBox(height: 16),

                  _ProfileMenuTile(
                    icon: Icons.history,
                    title: 'Lịch sử thuê xe',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryPage()));
                    },
                  ),

                  if (user.role == UserRole.user) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('CHO THUÊ XE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    _ProfileMenuTile(icon: Icons.add_a_photo, title: 'Đăng ký xe cho thuê ',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarPage()))),
                    _ProfileMenuTile(icon: Icons.list_alt, title: 'Danh sách xe của tôi', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCarsPage()))),
                  ],

                  if (user.role == UserRole.admin) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('DÀNH CHO QUẢN TRỊ VIÊN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    _ProfileMenuTile(icon: Icons.dashboard, title: 'Dashboard tổng quan', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()))),
                    _ProfileMenuTile(icon: Icons.people, title: 'Quản lý người dùng', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage()))),
                    _ProfileMenuTile(icon: Icons.verified_user, title: 'Duyệt xe hệ thống', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemCarApprovalPage()))),
                  ],

                  const Divider(),
                  _ProfileMenuTile(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    textColor: Colors.red,
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Vui lòng đăng nhập'));
        },
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin: return 'Quản trị viên';
      case UserRole.user: return 'Người dùng';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin: return Colors.purple;
      case UserRole.user: return Colors.blue;
    }
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  const _ProfileMenuTile({required this.icon, required this.title, required this.onTap, this.textColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
