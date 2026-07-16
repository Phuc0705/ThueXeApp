import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<String>> getFavorites(String userId);
  Future<void> addFavorite(String userId, String carId);
  Future<void> removeFavorite(String userId, String carId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final SupabaseClient supabase;

  FavoriteRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<String>> getFavorites(String userId) async {
    final response = await supabase
        .from('favorite_cars')
        .select('car_id')
        .eq('user_id', userId);
        
    return (response as List).map((json) => json['car_id'] as String).toList();
  }

  @override
  Future<void> addFavorite(String userId, String carId) async {
    // Upsert or insert (ignore conflicts if already exists)
    try {
      await supabase.from('favorite_cars').insert({
        'user_id': userId,
        'car_id': carId,
      });
    } catch (e) {
      // Ignore error if already exists due to unique constraint
    }
  }

  @override
  Future<void> removeFavorite(String userId, String carId) async {
    await supabase
        .from('favorite_cars')
        .delete()
        .match({'user_id': userId, 'car_id': carId});
  }
}
