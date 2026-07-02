<<<<<<< HEAD
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
    const UserEntity(id: '2', email: 'owner@gmail.com', fullName: 'Nguyen Van A', role: UserRole.owner),
    const UserEntity(id: '3', email: 'customer@gmail.com', fullName: 'Tran Thi B', role: UserRole.customer),
  ];

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
                const PopupMenuItem(value: 'lock', child: Text('Khóa tài khoản')),
                const PopupMenuItem(value: 'change_role', child: Text('Đổi vai trò')),
              ],
              onSelected: (value) {
                // Logic xử lý
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
      case UserRole.owner: return 'Chủ xe';
      case UserRole.customer: return 'Khách hàng';
    }
  }
}
=======
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
    const UserEntity(id: '2', email: 'owner@gmail.com', fullName: 'Nguyen Van A', role: UserRole.owner),
    const UserEntity(id: '3', email: 'customer@gmail.com', fullName: 'Tran Thi B', role: UserRole.customer),
  ];

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
                const PopupMenuItem(value: 'lock', child: Text('Khóa tài khoản')),
                const PopupMenuItem(value: 'change_role', child: Text('Đổi vai trò')),
              ],
              onSelected: (value) {
                // Logic xử lý
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
      case UserRole.owner: return 'Chủ xe';
      case UserRole.customer: return 'Khách hàng';
    }
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
