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
  Future<List<CarModel>> getTrendingCars({int limit = 5});
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
    // Tự động dọn dẹp các chuyến xe đã hết hạn (self-healing)
    try {
      final nowStr = DateTime.now().toIso8601String().split('T')[0];
      final expiredBookingsResponse = await supabase
          .from('bookings')
          .select('id, car_id')
          .eq('status', 'approved')
          .lt('end_date', nowStr);
          
      final expiredBookings = expiredBookingsResponse as List;
      for (var b in expiredBookings) {
        // Cập nhật booking thành completed
        await supabase.from('bookings').update({'status': 'completed'}).eq('id', b['id']);
        
        // Trả xe về available chỉ khi không còn đơn nào đang thuê
        final activeCheck = await supabase
            .from('bookings')
            .select('id')
            .eq('car_id', b['car_id'])
            .eq('status', 'approved')
            .gte('end_date', nowStr)
            .limit(1);
            
        if ((activeCheck as List).isEmpty) {
          await supabase.from('cars').update({'status': 'available'}).eq('id', b['car_id']);
        }
      }
    } catch (e) {
      // Bỏ qua lỗi dọn dẹp để không làm gián đoạn fetch cars
    }

    var dbQuery = supabase.from('cars').select('*, profiles(phone)').inFilter('status', ['available', 'rented']);
    
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

  @override
  Future<List<CarModel>> getTrendingCars({int limit = 5}) async {
    try {
      final favResponse = await supabase.from('favorite_cars').select('car_id');
      final favs = favResponse as List;
      print('getTrendingCars: favs length = ${favs.length}');
      
      final Map<String, int> counts = {};
      for (var f in favs) {
        final carId = f['car_id'] as String;
        counts[carId] = (counts[carId] ?? 0) + 1;
      }
      print('getTrendingCars: counts = $counts');
      
      if (counts.isEmpty) return [];

      final sortedCarIds = counts.keys.toList()
        ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
        
      final topCarIds = sortedCarIds.take(limit).toList();
      print('getTrendingCars: topCarIds = $topCarIds');
      
      final carsResponse = await supabase
          .from('cars')
          .select('*, profiles(phone)')
          .inFilter('id', topCarIds);
          
      final carsList = (carsResponse as List).map((json) => CarModel.fromJson(json)).toList();
      print('getTrendingCars: carsList length = ${carsList.length}');
      
      carsList.sort((a, b) {
        return topCarIds.indexOf(a.id).compareTo(topCarIds.indexOf(b.id));
      });
      
      return carsList;
    } catch (e) {
      print('getTrendingCars Exception: $e');
      rethrow;
    }
  }
}
