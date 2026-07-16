import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../../../car_browsing/presentation/bloc/car_bloc.dart';
import '../../../car_browsing/presentation/bloc/car_event.dart';
import '../../../car_browsing/presentation/bloc/car_state.dart';
import '../../../car_browsing/presentation/widgets/car_card.dart';

class SystemCarManagementPage extends StatefulWidget {
  const SystemCarManagementPage({super.key});

  @override
  State<SystemCarManagementPage> createState() => _SystemCarManagementPageState();
}

class _SystemCarManagementPageState extends State<SystemCarManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(FetchCarsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Quản lý xe hệ thống'),
      body: BlocBuilder<CarBloc, CarState>(
        builder: (context, state) {
          if (state is CarLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CarError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          } else if (state is CarLoaded) {
            final cars = state.cars;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tổng số xe trong hệ thống: ${cars.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: cars.map((car) => CarCard(car: car)).toList(),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
    );
  }
}
