import 'package:flutter/material.dart';

import '../../../../core/widgets/gradient_app_bar.dart';

class SystemCarManagementPage extends StatelessWidget {
  const SystemCarManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Quản lý xe hệ thống'),
      body: const Center(
        child: Text('Tính năng đang phát triển'),
      ),
    );
  }
}
