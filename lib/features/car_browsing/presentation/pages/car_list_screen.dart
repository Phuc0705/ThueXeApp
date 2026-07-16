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
  List<String> _selectedBrands = [];
  List<String> _selectedFuels = [];
  List<String> _selectedSeats = [];
  List<String> _selectedDistricts = [];

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

                  if (_selectedBrands.isNotEmpty) {
                    filteredCars = filteredCars.where((c) => _selectedBrands.contains(c.brand)).toList();
                  }
                  if (_selectedFuels.isNotEmpty) {
                    filteredCars = filteredCars.where((c) {
                      bool match = false;
                      for (String fuel in _selectedFuels) {
                        if (fuel == 'Điện') {
                          match = match || c.type.toLowerCase().contains('electric') || c.type.toLowerCase().contains('điện');
                        } else if (fuel == 'Dầu') {
                          match = match || c.type.toLowerCase().contains('diesel') || c.type.toLowerCase().contains('dầu');
                        } else {
                          match = match || (!c.type.toLowerCase().contains('electric') && !c.type.toLowerCase().contains('điện'));
                        }
                      }
                      return match;
                    }).toList();
                  }
                  if (_selectedSeats.isNotEmpty) {
                    List<int> seatsToFilter = _selectedSeats.map((s) => int.parse(s.split(' ')[0])).toList();
                    filteredCars = filteredCars.where((c) => seatsToFilter.contains(c.seats)).toList();
                  }
                  if (_selectedDistricts.isNotEmpty) {
                    filteredCars = filteredCars.where((c) => _selectedDistricts.contains(c.location)).toList();
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
            _showFilterOptions('Hãng xe', ['Toyota', 'Honda', 'Ford', 'Mercedes', 'BMW', 'Audi', 'Hyundai', 'Kia', 'Mazda', 'VinFast'], List.from(_selectedBrands), (val) {
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
                  Expanded(
                    child: ListView(
                      children: options.map((option) {
                        final isSelected = currentValues.contains(option);
                        return CheckboxListTile(
                          title: Text(option),
                          value: isSelected,
                          activeColor: Colors.blue,
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
}
