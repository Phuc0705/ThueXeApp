<<<<<<< HEAD
import 'package:flutter/material.dart';

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doanh thu của tôi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text('Tổng thu nhập (Tháng này)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('\$2,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chi tiết giao dịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.filter_list),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.add, color: Colors.white)),
                  title: Text('Thuê xe Tesla Model 3 - Giao dịch #$index'),
                  subtitle: const Text('20/10/2023'),
                  trailing: const Text('+\$150', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doanh thu của tôi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text('Tổng thu nhập (Tháng này)', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('\$2,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chi tiết giao dịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.filter_list),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.add, color: Colors.white)),
                  title: Text('Thuê xe Tesla Model 3 - Giao dịch #$index'),
                  subtitle: const Text('20/10/2023'),
                  trailing: const Text('+\$150', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
