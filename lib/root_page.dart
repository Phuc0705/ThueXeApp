import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/car_browsing/presentation/pages/car_list_screen.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Authenticated) {
          if (state.user.role == UserRole.admin) {
            return const AdminDashboardPage();
          }
          return const CarListScreen();
        }

        // Unauthenticated or Error -> Show public home
        return const CarListScreen();
      },
    );
  }
}
