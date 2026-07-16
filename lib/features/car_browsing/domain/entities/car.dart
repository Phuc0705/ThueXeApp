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
  final String ownerPhone;
  final String location;
  final String description;
  final int seats;
  final String status;

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.imageUrl,
    required this.type,
    required this.isAvailable,
    this.ownerId = '',
    this.ownerPhone = '',
    this.location = 'Quận 1',
    this.description = '',
    this.seats = 4,
    this.status = 'available',
  });

  @override
  List<Object?> get props => [id, name, brand, pricePerDay, imageUrl, type, isAvailable, ownerId, ownerPhone, location, description, seats, status];
}