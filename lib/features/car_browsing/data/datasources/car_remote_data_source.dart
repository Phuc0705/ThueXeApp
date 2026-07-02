import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';

abstract class CarRemoteDataSource {
  Future<List<CarModel>> getCars({
    String? query,
    String? type,
    String? fuelType,
    String? transmission,
    double? maxPrice,
  });
}

class CarRemoteDataSourceImpl implements CarRemoteDataSource {
  final SupabaseClient supabase;

  CarRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<CarModel>> getCars({
    String? query,
    String? type,
    String? fuelType,
    String? transmission,
    double? maxPrice,
  }) async {
    var dbQuery = supabase.from('cars').select();
    
    if (query != null && query.isNotEmpty) {
      dbQuery = dbQuery.ilike('name', '%$query%');
    }
    if (type != null && type.isNotEmpty) {
      dbQuery = dbQuery.eq('type', type);
    }
    if (fuelType != null && fuelType.isNotEmpty) {
      dbQuery = dbQuery.eq('fuel_type', fuelType);
    }
    if (transmission != null && transmission.isNotEmpty) {
      dbQuery = dbQuery.eq('transmission', transmission);
    }
    if (maxPrice != null && maxPrice > 0) {
      dbQuery = dbQuery.lte('price_per_day', maxPrice);
    }

    final response = await dbQuery;
    
    // Convert to List<CarModel>
    return (response as List).map((json) => CarModel.fromJson(json)).toList();
  }
}
