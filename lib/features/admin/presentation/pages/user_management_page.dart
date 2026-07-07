import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  // Mock data
  final List<UserEntity> _users = [
    const UserEntity(id: '1', email: 'admin@gmail.com', fullName: 'System Admin', role: UserRole.admin),
    const UserEntity(id: '2', email: 'user1@gmail.com', fullName: 'Nguyen Van A', role: UserRole.user, phoneNumber: '0987654321', idCard: '123456789'),
    const UserEntity(id: '3', email: 'user2@gmail.com', fullName: 'Tran Thi B', role: UserRole.user),
  ];

  void _showEditUserDialog(UserEntity user) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final cccdController = TextEditingController(text: user.idCard ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa người dùng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ tên')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
              TextField(controller: cccdController, decoration: const InputDecoration(labelText: 'CCCD')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                // TODO: Gọi API cập nhật user qua Supabase Admin API hoặc Backend
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.fullName),
            subtitle: Text('${user.email} • ${_getRoleText(user.role)}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa thông tin')),
                const PopupMenuItem(value: 'lock', child: Text('Khóa tài khoản')),
                const PopupMenuItem(value: 'change_role', child: Text('Đổi vai trò')),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditUserDialog(user);
                }
              },
            ),
          );
        },
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin: return 'Admin';
      case UserRole.user: return 'Người dùng';
    }
  }
}
