import 'package:flutter/material.dart';
import '../../domain/entities/car.dart';
import '../widgets/car_card.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

class SearchCarScreen extends StatelessWidget {
  final String title;
  final List<Car> cars;

  const SearchCarScreen({
    super.key,
    required this.title,
    required this.cars,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        title: title,
      ),
      body: cars.isEmpty
          ? const Center(child: Text('Không tìm thấy xe phù hợp.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: CarCard(car: cars[index]),
                  ),
                );
              },
            ),
    );
  }
}
