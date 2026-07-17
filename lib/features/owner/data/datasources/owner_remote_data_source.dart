import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../car_browsing/data/models/car_model.dart';

abstract class OwnerRemoteDataSource {
  Future<CarModel> addCar({
    required String name,
    required String brand,
    required double pricePerDay,
    required String type,
    required String fuelType,
    required String transmission,
    required String location,
    required String description,
    required int seats,
    required XFile carImage,
    required XFile docFrontImage,
    required XFile docBackImage,
  });
  Future<List<CarModel>> getMyCars();
  Future<void> deleteCar(String carId);
  Future<void> updateCarStatus(String carId, String status);
}

class OwnerRemoteDataSourceImpl implements OwnerRemoteDataSource {
  final SupabaseClient supabase;

  OwnerRemoteDataSourceImpl(this.supabase);

  Future<String> _uploadImage(XFile image, String prefix) async {
    final ext = image.path.split('.').last;
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final bytes = await image.readAsBytes();
    await supabase.storage.from('cars').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return supabase.storage.from('cars').getPublicUrl(fileName);
  }

  @override
  Future<CarModel> addCar({
    required String name,
    required String brand,
    required double pricePerDay,
    required String type,
    required String fuelType,
    required String transmission,
    required String location,
    required String description,
    required int seats,
    required XFile carImage,
    required XFile docFrontImage,
    required XFile docBackImage,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Bạn chưa đăng nhập!');

      // Upload images
      final carUrl = await _uploadImage(carImage, 'car');
      final docFrontUrl = await _uploadImage(docFrontImage, 'doc_front');
      final docBackUrl = await _uploadImage(docBackImage, 'doc_back');

      // Insert to database
      final response = await supabase.from('cars').insert({
        'name': name,
        'brand': brand,
        'price_per_day': pricePerDay,
        'type': type,
        'fuel_type': fuelType,
        'transmission': transmission,
        'location': location,
        'description': description,
        'seats': seats,
        'image_urls': [carUrl],
        'document_urls': [docFrontUrl, docBackUrl],
        'owner_id': user.id,
        'status': 'pending',
      }).select().single();

      return CarModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<CarModel>> getMyCars() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Bạn chưa đăng nhập!');

      final response = await supabase
          .from('cars')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => CarModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteCar(String carId) async {
    try {
      await supabase.from('cars').delete().eq('id', carId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateCarStatus(String carId, String status) async {
    try {
      await supabase.from('cars').update({'status': status}).eq('id', carId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
