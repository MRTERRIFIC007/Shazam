import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shazam/services/models/song_history_model.dart';
import 'package:shazam/services/song_history_service.dart';

final songHistoryProvider = ChangeNotifierProvider<SongHistoryViewModel>((ref) {
  return SongHistoryViewModel();
});

class SongHistoryViewModel extends ChangeNotifier {
  final SongHistoryService _historyService = SongHistoryService();
  List<SongHistoryItem> _songHistory = [];
  bool _isLoading = false;
  String? _error;

  List<SongHistoryItem> get songHistory => _songHistory;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  SongHistoryViewModel() {
    loadSongHistory();
  }

  Future<void> loadSongHistory() async {
    _setLoading(true);
    _clearError();

    try {
      _songHistory = await _historyService.getSongHistory();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load song history: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearSongHistory() async {
    _setLoading(true);
    _clearError();

    try {
      await _historyService.clearSongHistory();
      _songHistory = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear song history: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeSongFromHistory(int index) async {
    if (index < 0 || index >= _songHistory.length) {
      _setError('Invalid song index');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _historyService.removeSongFromHistory(index);
      _songHistory.removeAt(index);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove song from history: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
