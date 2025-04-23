import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shazam/models/song.dart';
import 'package:shazam/services/models/deezer_song_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  // Add a song to favorites
  Future<void> addToFavorites(DeezerSongModel deezerSong) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final song = Song.fromDeezerModel(deezerSong);

      // Get existing favorites
      final List<Song> favorites = await getFavorites();

      // Check if song already exists in favorites
      if (favorites.any((s) => s.id == song.id)) {
        return; // Song is already in favorites
      }

      // Add the new song
      favorites.add(song);

      // Save back to SharedPreferences
      final List<String> encodedList =
          favorites.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_favoritesKey, encodedList);
    } catch (e) {
      print('Error adding song to favorites: $e');
    }
  }

  // Remove a song from favorites
  Future<void> removeFromFavorites(int songId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing favorites
      final List<Song> favorites = await getFavorites();

      // Remove song with matching ID
      favorites.removeWhere((song) => song.id == songId);

      // Save back to SharedPreferences
      final List<String> encodedList =
          favorites.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_favoritesKey, encodedList);
    } catch (e) {
      print('Error removing song from favorites: $e');
    }
  }

  // Check if a song is in favorites
  Future<bool> isFavorite(int songId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((song) => song.id == songId);
    } catch (e) {
      print('Error checking if song is favorite: $e');
      return false;
    }
  }

  // Get all favorites
  Future<List<Song>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? encodedList = prefs.getStringList(_favoritesKey);

      if (encodedList == null || encodedList.isEmpty) {
        return [];
      }

      return encodedList
          .map((item) => Song.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error retrieving favorites: $e');
      return [];
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }
}
