import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../car_browsing/presentation/pages/car_detail_screen.dart';
import '../../../car_browsing/data/models/car_model.dart';
import '../../../../core/constants/car_constants.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class SystemCarManagementPage extends StatefulWidget {
  const SystemCarManagementPage({super.key});

  @override
  State<SystemCarManagementPage> createState() => _SystemCarManagementPageState();
}

class _SystemCarManagementPageState extends State<SystemCarManagementPage> {
  List<String> _selectedBrands = [];
  List<String> _selectedFuels = [];
  List<String> _selectedSeats = [];
  List<String> _selectedDistricts = [];

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchSystemCars());
  }

  void _showFilterOptions(String title, List<String> options, List<String> currentValues, Function(List<String>) onSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: options.map((option) {
                        final isSelected = currentValues.contains(option);
                        return CheckboxListTile(
                          title: Text(option),
                          value: isSelected,
                          activeColor: const Color(0xFF4A00E0),
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                currentValues.add(option);
                              } else {
                                currentValues.remove(option);
                              }
                            });
                            onSelected(List.from(currentValues));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Bỏ chọn tất cả', textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                    onTap: () {
                      setModalState(() {
                        currentValues.clear();
                      });
                      onSelected(List.from(currentValues));
                    },
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterChip(String label, {bool hasIcon = false, bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A00E0).withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF4A00E0) : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(
              color: isSelected ? const Color(0xFF4A00E0) : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )),
            if (hasIcon) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? const Color(0xFF4A00E0) : Colors.grey[600]),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    bool isAll = _selectedBrands.isEmpty && _selectedFuels.isEmpty && _selectedSeats.isEmpty && _selectedDistricts.isEmpty;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('Tất cả', isSelected: isAll, onTap: () {
            setState(() {
              _selectedBrands.clear();
              _selectedFuels.clear();
              _selectedSeats.clear();
              _selectedDistricts.clear();
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedDistricts.isNotEmpty ? 'Khu vực (${_selectedDistricts.length})' : 'Khu vực', hasIcon: true, isSelected: _selectedDistricts.isNotEmpty, onTap: () {
            _showFilterOptions('Khu vực', ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6', 'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12', 'Bình Thạnh', 'Thủ Đức', 'Gò Vấp', 'Phú Nhuận', 'Tân Bình', 'Tân Phú', 'Bình Tân'], List.from(_selectedDistricts), (val) {
              setState(() => _selectedDistricts = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedBrands.isNotEmpty ? 'Hãng xe (${_selectedBrands.length})' : 'Hãng xe', hasIcon: true, isSelected: _selectedBrands.isNotEmpty, onTap: () {
            _showFilterOptions('Hãng xe', CarConstants.carBrands.where((b) => b != 'Khác').toList(), List.from(_selectedBrands), (val) {
              setState(() => _selectedBrands = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedSeats.isNotEmpty ? 'Số chỗ (${_selectedSeats.length})' : 'Số chỗ', hasIcon: true, isSelected: _selectedSeats.isNotEmpty, onTap: () {
            _showFilterOptions('Số chỗ', ['4 chỗ', '5 chỗ', '7 chỗ'], List.from(_selectedSeats), (val) {
              setState(() => _selectedSeats = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedFuels.isNotEmpty ? 'Nhiên liệu (${_selectedFuels.length})' : 'Nhiên liệu', hasIcon: true, isSelected: _selectedFuels.isNotEmpty, onTap: () {
            _showFilterOptions('Nhiên liệu', ['Xăng', 'Dầu', 'Điện'], List.from(_selectedFuels), (val) {
              setState(() => _selectedFuels = val);
            });
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Quản lý xe hệ thống',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdminBloc>().add(FetchSystemCars());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              buildWhen: (previous, current) => current is AdminSystemCarsLoaded || current is AdminLoading || current is AdminError,
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminSystemCarsLoaded) {
                  List<Map<String, dynamic>> filteredCars = state.cars;

                  if (_selectedBrands.isNotEmpty) {
                    filteredCars = filteredCars.where((c) => _selectedBrands.contains(c['brand'])).toList();
                  }
                  if (_selectedSeats.isNotEmpty) {
                    final seatVals = _selectedSeats.map((s) => int.tryParse(s.split(' ')[0])).whereType<int>().toList();
                    if (seatVals.isNotEmpty) {
                      filteredCars = filteredCars.where((c) => seatVals.contains(c['seats'])).toList();
                    }
                  }
                  if (_selectedFuels.isNotEmpty) {
                    filteredCars = filteredCars.where((c) => _selectedFuels.contains(c['fuel_type'])).toList();
                  }
                  if (_selectedDistricts.isNotEmpty) {
                    filteredCars = filteredCars.where((c) => _selectedDistricts.contains(c['location'])).toList();
                  }

                  return _buildCarList(filteredCars);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarList(List<Map<String, dynamic>> cars) {
    if (cars.isEmpty) {
      return const Center(child: Text('Không tìm thấy xe nào phù hợp.'));
    }

    return ListView.builder(
      itemCount: cars.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final carMap = cars[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              ListTile(
                leading: _buildCarImage(carMap),
                title: Text('Xe: ${carMap['name']} (${carMap['brand']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Khu vực: ${carMap['location']}\nGiá: \$${carMap['price_per_day']}/ngày\nTrạng thái: ${_getStatusString(carMap['status'])}'),
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
                      child: const Text('Xem chi tiết', style: TextStyle(color: Color(0xFF4A00E0), fontWeight: FontWeight.bold)),
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

  String _getStatusString(String? status) {
    switch (status) {
      case 'available': return 'Sẵn sàng';
      case 'pending': return 'Chờ duyệt';
      case 'rented': return 'Đang thuê';
      case 'rejected': return 'Bị từ chối';
      case 'unavailable': return 'Đã ẩn';
      default: return status ?? 'Không rõ';
    }
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
