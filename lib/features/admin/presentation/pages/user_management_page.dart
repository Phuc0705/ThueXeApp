import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchAllUsers());
  }

  void _showEditUserDialog(UserEntity user) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Chỉnh sửa người dùng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ tên')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                context.read<AdminBloc>().add(
                      UpdateUserInfo(
                        user.id,
                        nameController.text,
                        phoneController.text,
                      ),
                    );
                Navigator.pop(ctx);
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
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(FetchAllUsers());
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.red))));
          }
        },
        buildWhen: (previous, current) => current is AdminUsersLoaded || current is AdminLoading || current is AdminError,
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminUsersLoaded) {
            final users = state.users;
            if (users.isEmpty) return const Center(child: Text('Không có người dùng nào.'));

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.fullName),
                  subtitle: Text('${user.email} • ${_getRoleText(user.role)}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa thông tin')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa tài khoản', style: TextStyle(color: Colors.red))),
                      PopupMenuItem(
                        value: 'change_role', 
                        child: Text(user.role == UserRole.admin ? 'Hạ quyền thành User' : 'Nâng quyền thành Admin'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditUserDialog(user);
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(user);
                      } else if (value == 'change_role') {
                        final newRole = user.role == UserRole.admin ? 'user' : 'admin';
                        context.read<AdminBloc>().add(ChangeUserRoleEvent(user.id, newRole));
                      }
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
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

  void _showDeleteConfirmDialog(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng ${user.fullName} không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AdminBloc>().add(DeleteUserEvent(user.id));
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
