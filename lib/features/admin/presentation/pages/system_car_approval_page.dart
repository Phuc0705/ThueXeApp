import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../car_browsing/presentation/pages/car_detail_screen.dart';
import '../../../car_browsing/data/models/car_model.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class SystemCarApprovalPage extends StatefulWidget {
  const SystemCarApprovalPage({super.key});

  @override
  State<SystemCarApprovalPage> createState() => _SystemCarApprovalPageState();
}

class _SystemCarApprovalPageState extends State<SystemCarApprovalPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchPendingCars());
  }

  void _showConfirmDialog(String carId, String carName, bool isApprove) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApprove ? 'Phê duyệt xe' : 'Từ chối xe'),
        content: Text(isApprove 
            ? 'Bạn có chắc chắn muốn duyệt xe "$carName" cho phép hiển thị lên hệ thống?'
            : 'Bạn có chắc chắn muốn từ chối xe "$carName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isApprove ? Colors.green : Colors.red),
            onPressed: () {
              context.read<AdminBloc>().add(ApproveCarEvent(carId, isApprove));
              Navigator.pop(ctx);
            },
            child: Text(isApprove ? 'Phê duyệt' : 'Từ chối', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Duyệt xe hệ thống',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdminBloc>().add(FetchPendingCars());
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
        buildWhen: (previous, current) => current is AdminPendingCarsLoaded || current is AdminLoading || current is AdminError,
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminPendingCarsLoaded) {
            final cars = state.cars;
            if (cars.isEmpty) {
              return const Center(child: Text('Không có xe nào đang chờ duyệt.'));
            }

            return ListView.builder(
              itemCount: cars.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final carMap = cars[index];
                final ownerName = carMap['owner_id'] ?? 'Không rõ';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: _buildCarImage(carMap),
                        title: Text('Xe: ${carMap['name']} (${carMap['brand']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Chủ xe: $ownerName\nGiá: \$${carMap['price_per_day']}/ngày'),
                        isThreeLine: true,
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                final carModel = CarModel.fromJson(carMap);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CarDetailScreen(car: carModel)),
                                );
                              },
                              child: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _showConfirmDialog(carMap['id'], carMap['name'], false),
                              child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _showConfirmDialog(carMap['id'], carMap['name'], true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Phê duyệt', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    ],
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

  Widget _buildCarImage(Map<String, dynamic> carMap) {
    String imageUrl = '';
    if (carMap['image_urls'] != null && (carMap['image_urls'] as List).isNotEmpty) {
      imageUrl = carMap['image_urls'][0];
    } else if (carMap['image_url'] != null) {
      imageUrl = carMap['image_url'];
    }

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, size: 40),
        ),
      );
    }
    return const Icon(Icons.directions_car, size: 40);
  }
}
