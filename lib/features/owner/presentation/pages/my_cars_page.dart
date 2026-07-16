import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../car_browsing/domain/entities/car.dart';
import 'add_car_page.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class MyCarsPage extends StatefulWidget {
  const MyCarsPage({super.key});

  @override
  State<MyCarsPage> createState() => _MyCarsPageState();
}

class _MyCarsPageState extends State<MyCarsPage> {
  List<Car> _myCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyCars();
  }

  Future<void> _fetchMyCars() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('cars')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _myCars = (response as List).map((json) => Car(
          id: json['id'],
          name: json['name'],
          brand: json['brand'],
          pricePerDay: (json['price_per_day'] as num).toDouble(),
          imageUrl: (json['image_urls'] as List).isNotEmpty ? json['image_urls'][0] : '',
          type: json['type'],
          isAvailable: json['status'] == 'available',
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách xe: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Xe của tôi'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCars.isEmpty
              ? const Center(child: Text('Bạn chưa đăng ký cho thuê chiếc xe nào.'))
              : ListView.builder(
                  itemCount: _myCars.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final car = _myCars[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: car.imageUrl.isNotEmpty 
                                ? DecorationImage(image: NetworkImage(car.imageUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: car.imageUrl.isEmpty ? const Icon(Icons.directions_car, color: Colors.blue) : null,
                        ),
                        title: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${car.type} • \$${car.pricePerDay}/ngày'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(car.isAvailable ? 'Sẵn sàng' : 'Đang thuê', 
                              style: TextStyle(color: car.isAvailable ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          // Navigate to edit car or view details
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarPage()));
          _fetchMyCars(); // Refresh sau khi thêm xe
        },
        label: const Text('Thêm xe mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
