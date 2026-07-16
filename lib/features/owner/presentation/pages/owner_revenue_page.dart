import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class OwnerRevenuePage extends StatelessWidget {
  const OwnerRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: GradientAppBar(title: 'Doanh thu cho thuê'),
      body: Center(
        child: Text('Tính năng đang phát triển', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
