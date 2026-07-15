import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_state.dart';
import '../bloc/favorite_cubit.dart';
import '../widgets/car_card.dart';

class FavoriteCarsScreen extends StatelessWidget {
  const FavoriteCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xe yêu thích'),
      ),
      body: BlocBuilder<FavoriteCubit, List<String>>(
        builder: (context, favorites) {
          if (favorites.isEmpty) {
            return const Center(child: Text('Bạn chưa có chiếc xe yêu thích nào.'));
          }

          return BlocBuilder<CarBloc, CarState>(
            builder: (context, carState) {
              if (carState is CarLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (carState is CarLoaded) {
                final favoriteCars = carState.cars.where((car) => favorites.contains(car.id)).toList();

                if (favoriteCars.isEmpty) {
                  return const Center(child: Text('Không tìm thấy dữ liệu các chiếc xe yêu thích.'));
                }

                return ListView.builder(
                  itemCount: favoriteCars.length,
                  itemBuilder: (context, index) {
                    return CarCard(car: favoriteCars[index]);
                  },
                );
              } else if (carState is CarError) {
                return Center(child: Text('Lỗi: ${carState.message}'));
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}
