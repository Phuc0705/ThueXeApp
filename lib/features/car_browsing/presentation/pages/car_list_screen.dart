import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import '../widgets/car_card.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final _searchController = TextEditingController();
  String _selectedType = '';
  String _selectedFuelType = '';
  String _selectedTransmission = '';
  double _maxPrice = 0;

  void _applyFilters() {
    context.read<CarBloc>().add(FetchCarsEvent(
      query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      type: _selectedType.isEmpty ? null : _selectedType,
      fuelType: _selectedFuelType.isEmpty ? null : _selectedFuelType,
      transmission: _selectedTransmission.isEmpty ? null : _selectedTransmission,
      maxPrice: _maxPrice > 0 ? _maxPrice : null,
    ));
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bộ lọc nâng cao', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Loại xe'),
                  Wrap(
                    spacing: 8,
                    children: ['SUV', 'Sedan', 'Electric', 'Luxury'].map((t) {
                      return ChoiceChip(
                        label: Text(t),
                        selected: _selectedType == t,
                        onSelected: (selected) {
                          setStateSB(() => _selectedType = selected ? t : '');
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Loại nhiên liệu'),
                  Wrap(
                    spacing: 8,
                    children: ['Xăng', 'Dầu', 'Điện'].map((t) {
                      return ChoiceChip(
                        label: Text(t),
                        selected: _selectedFuelType == t,
                        onSelected: (selected) {
                          setStateSB(() => _selectedFuelType = selected ? t : '');
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Hộp số'),
                  Wrap(
                    spacing: 8,
                    children: ['Số tự động', 'Số sàn'].map((t) {
                      return ChoiceChip(
                        label: Text(t),
                        selected: _selectedTransmission == t,
                        onSelected: (selected) {
                          setStateSB(() => _selectedTransmission = selected ? t : '');
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Mức giá tối đa: ${_maxPrice > 0 ? "\$${_maxPrice.toStringAsFixed(0)}/ngày" : "Không giới hạn"}'),
                  Slider(
                    value: _maxPrice,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    label: _maxPrice.toStringAsFixed(0),
                    onChanged: (val) {
                      setStateSB(() => _maxPrice = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text('ÁP DỤNG'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thuê Xe Tự Lái', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.blue,
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
                child: const Text('Đăng nhập'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm xe...',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _applyFilters,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: const Icon(Icons.filter_list),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả', 
                  isSelected: _selectedType.isEmpty,
                  onTap: () {
                    setState(() => _selectedType = '');
                    _applyFilters();
                  },
                ),
                _FilterChip(
                  label: 'SUV',
                  isSelected: _selectedType == 'SUV',
                  onTap: () {
                    setState(() => _selectedType = 'SUV');
                    _applyFilters();
                  },
                ),
                _FilterChip(
                  label: 'Sedan',
                  isSelected: _selectedType == 'Sedan',
                  onTap: () {
                    setState(() => _selectedType = 'Sedan');
                    _applyFilters();
                  },
                ),
                _FilterChip(
                  label: 'Electric',
                  isSelected: _selectedType == 'Electric',
                  onTap: () {
                    setState(() => _selectedType = 'Electric');
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CarBloc, CarState>(
              builder: (context, state) {
                if (state is CarLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CarLoaded) {
                  if (state.cars.isEmpty) {
                    return const Center(child: Text('Không tìm thấy xe phù hợp.'));
                  }
                  return ListView.builder(
                    itemCount: state.cars.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      return CarCard(car: state.cars[index]);
                    },
                  );
                } else if (state is CarError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  const _FilterChip({required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (onTap != null) onTap!();
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
