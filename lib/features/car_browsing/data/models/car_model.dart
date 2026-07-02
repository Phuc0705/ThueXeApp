<<<<<<< HEAD
import '../../domain/entities/car.dart';

class CarModel extends Car {
  const CarModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.pricePerDay,
    required super.imageUrl,
    required super.type,
    required super.isAvailable,
    super.ownerId,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      pricePerDay: (json['price_per_day'] ?? json['pricePerDay'] ?? 0).toDouble(),
      imageUrl: (json['image_urls'] != null && (json['image_urls'] as List).isNotEmpty)
          ? json['image_urls'][0]
          : (json['imageUrl'] ?? ''),
      type: json['type'] ?? '',
      isAvailable: json['status'] == 'available' || json['isAvailable'] == true,
      ownerId: json['owner_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price_per_day': pricePerDay,
      'image_urls': [imageUrl],
      'type': type,
      'status': isAvailable ? 'available' : 'rented',
    };
  }
}
=======
import '../../domain/entities/car.dart';

class CarModel extends Car {
  const CarModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.pricePerDay,
    required super.imageUrl,
    required super.type,
    required super.isAvailable,
    super.ownerId,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      pricePerDay: (json['price_per_day'] ?? json['pricePerDay'] ?? 0).toDouble(),
      imageUrl: (json['image_urls'] != null && (json['image_urls'] as List).isNotEmpty)
          ? json['image_urls'][0]
          : (json['imageUrl'] ?? ''),
      type: json['type'] ?? '',
      isAvailable: json['status'] == 'available' || json['isAvailable'] == true,
      ownerId: json['owner_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price_per_day': pricePerDay,
      'image_urls': [imageUrl],
      'type': type,
      'status': isAvailable ? 'available' : 'rented',
    };
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
