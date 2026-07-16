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
    super.location,
    required super.description,
    required super.seats,
    required super.status,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      pricePerDay: (json['price_per_day'] ?? json['pricePerDay'] ?? 0).toDouble(),
      imageUrl: (json['image_urls'] != null && (json['image_urls'] as List).isNotEmpty)
          ? json['image_urls'][0]
          : (json['image_url'] ?? json['imageUrl'] ?? ''),
      type: json['type'] ?? '',
      isAvailable: json['status'] == 'available' || json['isAvailable'] == true,
      ownerId: json['owner_id'] ?? '',
      location: json['location'] ?? _getMockLocation(json['id']),
      description: json['description'] ?? '',
      seats: json['seats'] ?? 4,
      status: json['status'] ?? (json['isAvailable'] == true ? 'available' : 'rented'),
    );
  }

  static String _getMockLocation(String? id) {
    if (id == null) return 'Quận 1';
    final districts = ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 7', 'Thủ Đức', 'Bình Thạnh', 'Tân Bình', 'Gò Vấp'];
    return districts[id.hashCode.abs() % districts.length];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price_per_day': pricePerDay,
      'image_urls': [imageUrl],
      'type': type,
      'status': status,
      'location': location,
      'description': description,
      'seats': seats,
    };
  }
}
