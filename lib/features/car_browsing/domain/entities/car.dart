import 'package:equatable/equatable.dart';

class Car extends Equatable {
  final String id;
  final String name;
  final String brand;
  final double pricePerDay;
  final String imageUrl;
  final String type; // SUV, Sedan, Electric, etc.
  final bool isAvailable;
  final String ownerId;
  final String location;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.imageUrl,
    required this.type,
    required this.isAvailable,
    this.ownerId = '',
    this.location = 'Quận 1',
  });

  @override
  List<Object?> get props => [id, name, brand, pricePerDay, imageUrl, type, isAvailable, ownerId, location];
}