import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/car.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import '../bloc/favorite_cubit.dart';
import '../widgets/car_card.dart';
import 'search_car_screen.dart';
import 'favorite_cars_screen.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  String? _selectedBrand;
  String? _selectedFuel;
  String? _selectedSeats;
  String? _selectedDistrict;
  String? _selectedDelivery;

  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(FetchCarsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        title: 'Thuê Xe Tự Lái',
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                  },
                );
              }
              return TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteCarsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterBar(),
            BlocBuilder<CarBloc, CarState>(
              builder: (context, state) {
                if (state is CarLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.blue)),
                  );
                } else if (state is CarLoaded) {
                  var filteredCars = state.cars;

                  if (_selectedBrand != null) {
                    filteredCars = filteredCars.where((c) => c.brand.toLowerCase() == _selectedBrand!.toLowerCase()).toList();
                  }
                  if (_selectedFuel != null) {
                    if (_selectedFuel == 'Điện') {
                      filteredCars = filteredCars.where((c) => c.type.toLowerCase().contains('electric') || c.type.toLowerCase().contains('điện')).toList();
                    } else if (_selectedFuel == 'Dầu') {
                      // Không có xe dầu trong mock data, có thể bỏ qua hoặc fake
                      filteredCars = filteredCars.where((c) => c.type.toLowerCase().contains('diesel') || c.type.toLowerCase().contains('dầu')).toList();
                    } else { // Xăng
                      filteredCars = filteredCars.where((c) => !c.type.toLowerCase().contains('electric') && !c.type.toLowerCase().contains('điện')).toList();
                    }
                  }
                  if (_selectedSeats != null) {
                    if (_selectedSeats == '7 chỗ') {
                      filteredCars = filteredCars.where((c) => c.type.toLowerCase().contains('suv') || c.type.toLowerCase().contains('mpv')).toList();
                    } else { // 4 hoặc 5 chỗ
                      filteredCars = filteredCars.where((c) => !c.type.toLowerCase().contains('suv') && !c.type.toLowerCase().contains('mpv')).toList();
                    }
                  }
                  if (_selectedDistrict != null) {
                    filteredCars = filteredCars.where((c) => c.location == _selectedDistrict).toList();
                  }
                  if (_selectedDelivery != null) {
                    if (_selectedDelivery == 'Gặp chủ xe') {
                      filteredCars = filteredCars.where((c) => c.type.toLowerCase().contains('suv')).toList();
                    } else { // Tự nhận xe
                      filteredCars = filteredCars.where((c) => !c.type.toLowerCase().contains('suv')).toList();
                    }
                  }

                  if (filteredCars.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(child: Text('Không tìm thấy xe nào phù hợp với bộ lọc.')),
                    );
                  }

                  final availableCars = filteredCars.where((c) => c.isAvailable).toList();
                  final otherCars = filteredCars.where((c) => !c.isAvailable).toList();

                  return BlocBuilder<FavoriteCubit, List<String>>(
                    builder: (context, favorites) {
                      final favoriteCarList = filteredCars.where((c) => favorites.contains(c.id)).toList();

                      return Column(
                        children: [
                          _buildCarSection('Xe có ngay', availableCars.isNotEmpty ? availableCars : filteredCars),
                          _buildCarSection('Xe yêu thích', favoriteCarList, isFavoriteSection: true),
                          _buildCarSection('Xe đã thuê', otherCars), // Only rented cars
                          const SizedBox(height: 40),
                        ],
                      );
                    },
                  );
                } else if (state is CarError) {
                  return Padding(
                    padding: const EdgeInsets.all(50),
                    child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarSection(String title, List<Car> cars, {bool isFavoriteSection = false}) {
    if (cars.isEmpty) return const SizedBox();
    
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  if (isFavoriteSection) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteCarsScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => SearchCarScreen(title: title, cars: cars),
                    ));
                  }
                },
                child: const Text(
                  'Xem thêm >',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return CarCard(car: cars[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    bool isAll = _selectedBrand == null && _selectedFuel == null && _selectedSeats == null && _selectedDistrict == null && _selectedDelivery == null;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('Tất cả', isSelected: isAll, onTap: () {
            setState(() {
              _selectedBrand = null;
              _selectedFuel = null;
              _selectedSeats = null;
              _selectedDistrict = null;
              _selectedDelivery = null;
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedDistrict ?? 'Khu vực', hasIcon: true, isSelected: _selectedDistrict != null, onTap: () {
            _showFilterOptions('Khu vực (Quận/Huyện)', ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6', 'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12', 'Bình Thạnh', 'Phú Nhuận', 'Thủ Đức', 'Gò Vấp', 'Tân Bình', 'Tân Phú', 'Bình Tân', 'Hóc Môn', 'Củ Chi', 'Nhà Bè', 'Bình Chánh', 'Cần Giờ'], _selectedDistrict, (val) {
              setState(() => _selectedDistrict = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedBrand ?? 'Hãng xe', hasIcon: true, isSelected: _selectedBrand != null, onTap: () {
            _showFilterOptions('Hãng xe', ['Ford', 'Mercedes', 'Toyota', 'VinFast', 'Mazda', 'Honda', 'Suzuki', 'Hyundai', 'Kia', 'Mitsubishi', 'Porsche', 'Tesla'], _selectedBrand, (val) {
              setState(() => _selectedBrand = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedSeats ?? 'Số chỗ', hasIcon: true, isSelected: _selectedSeats != null, onTap: () {
            _showFilterOptions('Số chỗ', ['4 chỗ', '5 chỗ', '7 chỗ'], _selectedSeats, (val) {
              setState(() => _selectedSeats = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedFuel ?? 'Nhiên liệu', hasIcon: true, isSelected: _selectedFuel != null, onTap: () {
            _showFilterOptions('Nhiên liệu', ['Xăng', 'Dầu', 'Điện'], _selectedFuel, (val) {
              setState(() => _selectedFuel = val);
            });
          }),
          const SizedBox(width: 8),
          _buildFilterChip(_selectedDelivery ?? 'Hình thức', hasIcon: true, isSelected: _selectedDelivery != null, onTap: () {
            _showFilterOptions('Hình thức nhận xe', ['Tự nhận xe', 'Gặp chủ xe'], _selectedDelivery, (val) {
              setState(() => _selectedDelivery = val);
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, bool hasIcon = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) ...[
              Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(String title, List<String> options, String? currentValue, Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  bool isSelected = currentValue == option;
                  return InkWell(
                    onTap: () {
                      onSelected(isSelected ? null : option);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
