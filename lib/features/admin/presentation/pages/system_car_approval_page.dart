<<<<<<< HEAD
import 'package:flutter/material.dart';

class SystemCarApprovalPage extends StatelessWidget {
  const SystemCarApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt xe hệ thống')),
      body: ListView.builder(
        itemCount: 3, // Mock data
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.directions_car, size: 40),
                  title: Text('Yêu cầu đăng ký: Car Model $index'),
                  subtitle: Text('Chủ xe: Owner ID $index'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue))),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: () {}, child: const Text('Từ chối', style: TextStyle(color: Colors.red))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () {}, child: const Text('Phê duyệt')),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';

class SystemCarApprovalPage extends StatelessWidget {
  const SystemCarApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt xe hệ thống')),
      body: ListView.builder(
        itemCount: 3, // Mock data
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.directions_car, size: 40),
                  title: Text('Yêu cầu đăng ký: Car Model $index'),
                  subtitle: Text('Chủ xe: Owner ID $index'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue))),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: () {}, child: const Text('Từ chối', style: TextStyle(color: Colors.red))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () {}, child: const Text('Phê duyệt')),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
