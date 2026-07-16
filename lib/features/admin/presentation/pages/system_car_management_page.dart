import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class SystemCarManagementPage extends StatelessWidget {
  const SystemCarManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: GradientAppBar(title: 'Quản lý xe hệ thống'),
      body: Center(
        child: Text('Tính năng đang phát triển', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
