import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/car.dart';
import '../../../booking/presentation/pages/booking_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/pages/login_page.dart';

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[300],
                child: car.imageUrl.isNotEmpty
                    ? Image.network(
                        car.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, size: 100, color: Colors.white),
                      )
                    : const Icon(Icons.directions_car, size: 100, color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        car.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${car.pricePerDay}/ngày',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${car.brand} • ${car.type}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Đặc điểm xe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeatureChip(icon: Icons.ac_unit, label: 'Điều hòa'),
                      _FeatureChip(icon: Icons.bluetooth, label: 'Bluetooth'),
                      _FeatureChip(icon: Icons.gps_fixed, label: 'GPS'),
                      _FeatureChip(icon: Icons.camera_alt, label: 'Camera lùi'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mô tả xe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car.description.isNotEmpty ? car.description : 'Chiếc xe này đang trong tình trạng hoàn hảo, được bảo dưỡng định kỳ và đầy đủ bảo hiểm. Rất phù hợp cho các chuyến du lịch gia đình hoặc đi công tác xa.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vị trí xe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${car.location}, Hồ Chí Minh', style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Điều khoản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Không hút thuốc trong xe\n• Vui lòng giữ gìn vệ sinh\n• Trả xe đúng giờ và đúng lượng nhiên liệu ban đầu',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Thông tin chủ xe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(car.ownerPhone.isNotEmpty ? car.ownerPhone : 'Chưa cập nhật', style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const ExpansionTile(
                    title: Text(
                      'Chính sách hủy chuyến',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    tilePadding: EdgeInsets.zero,
                    expandedAlignment: Alignment.topLeft,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Text(
                          '• Miễn phí hủy chuyến trong vòng 24h sau khi thực hiện đặt xe.\n'
                              '• Hoàn tiền 100% nếu hủy chuyến trước thời gian nhận xe ít nhất 48h.\n'
                              '• Thu phí 50% giá trị đơn hàng nếu thực hiện hủy chuyến trong vòng 24h trước khi nhận xe.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isOwner = authState is Authenticated && authState.user.id == car.ownerId;
                  
                  return ElevatedButton(
                    onPressed: (car.isAvailable && !isOwner) ? () {
                      if (authState is Authenticated) {
                        if (authState.user.role == UserRole.admin) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quản trị viên không thể thực hiện đặt xe')),
                          );
                          return;
                        }
                        
                        // Đã đăng nhập và là user -> Cho phép vào trang đặt xe
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookingPage(car: car)),
                        );
                      } else {
                        // Chưa đăng nhập -> Thông báo và chuyển hướng login
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng đăng nhập để thực hiện đặt xe')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwner ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isOwner ? 'XE CỦA BẠN' : (car.isAvailable ? 'ĐẶT XE NGAY' : 'XE ĐÃ ĐƯỢC THUÊ')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}
