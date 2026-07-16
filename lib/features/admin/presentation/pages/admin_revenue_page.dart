import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class AdminRevenuePage extends StatelessWidget {
  const AdminRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: GradientAppBar(title: 'Quản lý doanh thu'),
      body: Center(
        child: Text('Tính năng đang phát triển', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
