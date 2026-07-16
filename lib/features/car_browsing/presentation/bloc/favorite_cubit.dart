import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/favorite_local_data_source.dart';
import '../../data/datasources/favorite_remote_data_source.dart';

class FavoriteCubit extends Cubit<List<String>> {
  final FavoriteLocalDataSource localDataSource;
  final FavoriteRemoteDataSource remoteDataSource;
  final SupabaseClient supabase;

  FavoriteCubit({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.supabase,
  }) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    // 1. Load local first for fast UI
    final localFavorites = await localDataSource.getFavorites();
    emit(localFavorites);

    // 2. Sync with remote if logged in
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        final remoteFavorites = await remoteDataSource.getFavorites(userId);
        
        // Merge remote and local
        final merged = {...localFavorites, ...remoteFavorites}.toList();
        
        // If there are differences, sync back
        if (merged.length != localFavorites.length) {
          emit(merged);
          await localDataSource.saveFavorites(merged);
          
          // Add local ones to remote that might be missing
          for (var carId in localFavorites) {
            if (!remoteFavorites.contains(carId)) {
              await remoteDataSource.addFavorite(userId, carId);
            }
          }
        }
      } catch (e) {
        // Ignore remote error, keep using local
      }
    }
  }

  Future<void> toggleFavorite(String carId) async {
    final List<String> currentFavorites = List.from(state);
    final isFavorite = currentFavorites.contains(carId);
    
    if (isFavorite) {
      currentFavorites.remove(carId);
    } else {
      currentFavorites.add(carId);
    }
    
    // Optimistic UI update
    emit(currentFavorites);
    await localDataSource.saveFavorites(currentFavorites);

    // Sync remote
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        if (isFavorite) {
          await remoteDataSource.removeFavorite(userId, carId);
        } else {
          await remoteDataSource.addFavorite(userId, carId);
        }
      } catch (e) {
        // Revert on error? Or just let it be.
      }
    }
  }
}
