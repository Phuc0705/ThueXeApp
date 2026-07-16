import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteLocalDataSource {
  String _getKey(String userId) => 'favorite_cars_$userId';

  Future<List<String>> getFavorites(String userId) async {
    if (userId.isEmpty) return [];
    
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_getKey(userId));
    if (favoritesJson != null) {
      return List<String>.from(json.decode(favoritesJson));
    }
    return [];
  }

  Future<void> saveFavorites(String userId, List<String> favorites) async {
    if (userId.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getKey(userId), json.encode(favorites));
  }
}
