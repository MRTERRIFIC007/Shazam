import 'package:shared_preferences/shared_preferences.dart';
import 'package:shazam/models/song.dart';
import 'package:shazam/services/models/song_history_model.dart';
import 'package:shazam/services/models/deezer_song_model.dart';

class SongHistoryService {
  static const String _historyKey = 'song_history';

  // Save a song to history
  Future<void> addSongToHistory(DeezerSongModel deezerSong) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final song = Song.fromDeezerModel(deezerSong);

      final songHistoryItem = SongHistoryItem(
        song: song,
        timestamp: DateTime.now(),
      );

      // Get existing history
      final List<SongHistoryItem> historyList = await getSongHistory();

      // Add the new item at the beginning
      historyList.insert(0, songHistoryItem);

      // Keep only the last 50 songs
      if (historyList.length > 50) {
        historyList.removeRange(50, historyList.length);
      }

      // Save back to SharedPreferences
      final encodedList = SongHistoryItem.encodeList(historyList);
      await prefs.setString(_historyKey, encodedList);
    } catch (e) {
      print('Error adding song to history: $e');
    }
  }

  // Get all song history
  Future<List<SongHistoryItem>> getSongHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedList = prefs.getString(_historyKey);

      if (encodedList == null || encodedList.isEmpty) {
        return [];
      }

      return SongHistoryItem.decodeList(encodedList);
    } catch (e) {
      print('Error retrieving song history: $e');
      return [];
    }
  }

  // Clear song history
  Future<void> clearSongHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing song history: $e');
    }
  }

  // Remove a specific song from history by index
  Future<void> removeSongFromHistory(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<SongHistoryItem> historyList = await getSongHistory();

      if (index >= 0 && index < historyList.length) {
        historyList.removeAt(index);

        // Save back to SharedPreferences
        final encodedList = SongHistoryItem.encodeList(historyList);
        await prefs.setString(_historyKey, encodedList);
      }
    } catch (e) {
      print('Error removing song from history: $e');
    }
  }
}
