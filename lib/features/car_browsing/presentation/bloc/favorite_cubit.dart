import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/favorite_local_data_source.dart';

class FavoriteCubit extends Cubit<List<String>> {
  final FavoriteLocalDataSource dataSource;

  FavoriteCubit({required this.dataSource}) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await dataSource.getFavorites();
    emit(favorites);
  }

  Future<void> toggleFavorite(String carId) async {
    final List<String> currentFavorites = List.from(state);
    if (currentFavorites.contains(carId)) {
      currentFavorites.remove(carId);
    } else {
      currentFavorites.add(carId);
    }
    
    await dataSource.saveFavorites(currentFavorites);
    emit(currentFavorites);
  }
}
