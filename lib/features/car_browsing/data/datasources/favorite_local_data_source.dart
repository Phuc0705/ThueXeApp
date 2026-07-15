import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteLocalDataSource {
  static const String _favoritesKey = 'favorite_cars';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      return List<String>.from(json.decode(favoritesJson));
    }
    return [];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, json.encode(favorites));
  }
}
