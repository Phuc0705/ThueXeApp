import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/favorite_local_data_source.dart';
import '../../data/datasources/favorite_remote_data_source.dart';

import 'dart:async';

class FavoriteCubit extends Cubit<List<String>> {
  final FavoriteLocalDataSource localDataSource;
  final FavoriteRemoteDataSource remoteDataSource;
  final SupabaseClient supabase;
  late final StreamSubscription<AuthState> _authSubscription;

  FavoriteCubit({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.supabase,
  }) : super([]) {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        emit([]);
      } else if (data.event == AuthChangeEvent.signedIn) {
        loadFavorites();
      }
    });
    loadFavorites();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  Future<void> loadFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      // If not logged in, clear favorites from memory
      emit([]);
      return;
    }

    // 1. Load local first for fast UI
    final localFavorites = await localDataSource.getFavorites(userId);
    emit(localFavorites);

    // 2. Sync with remote
    try {
      final remoteFavorites = await remoteDataSource.getFavorites(userId);
      
      // Merge remote and local
      final merged = {...localFavorites, ...remoteFavorites}.toList();
      
      // If there are differences, sync back
      if (merged.length != localFavorites.length || merged.length != remoteFavorites.length) {
        emit(merged);
        await localDataSource.saveFavorites(userId, merged);
        
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

  Future<void> toggleFavorite(String carId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return; // Unauthenticated users cannot favorite

    final List<String> currentFavorites = List.from(state);
    final isFavorite = currentFavorites.contains(carId);
    
    if (isFavorite) {
      currentFavorites.remove(carId);
    } else {
      currentFavorites.add(carId);
    }
    
    // Optimistic UI update
    emit(currentFavorites);
    await localDataSource.saveFavorites(userId, currentFavorites);

    // Sync remote
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
