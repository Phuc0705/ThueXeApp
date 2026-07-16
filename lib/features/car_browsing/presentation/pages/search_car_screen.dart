import 'package:flutter/material.dart';
import '../../domain/entities/car.dart';
import '../widgets/car_card.dart';

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
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: cars.isEmpty
          ? const Center(child: Text('Không tìm thấy xe phù hợp.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
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
