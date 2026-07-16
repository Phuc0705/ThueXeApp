import 'package:flutter/material.dart';

import '../../../../core/widgets/gradient_app_bar.dart';

class AdminRevenuePage extends StatelessWidget {
  const AdminRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Doanh thu hệ thống'),
      body: const Center(
        child: Text('Tính năng đang phát triển'),
      ),
    );
  }
}
