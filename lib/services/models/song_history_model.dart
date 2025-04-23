import 'dart:convert';
import 'package:shazam/models/song.dart';

class SongHistoryItem {
  final Song song;
  final DateTime timestamp;

  SongHistoryItem({
    required this.song,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'song': song.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SongHistoryItem.fromJson(Map<String, dynamic> json) {
    return SongHistoryItem(
      song: Song.fromJson(json['song']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  static List<SongHistoryItem> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SongHistoryItem.fromJson(json)).toList();
  }

  static String encodeList(List<SongHistoryItem> items) {
    final jsonList = items.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  static List<SongHistoryItem> decodeList(String encodedList) {
    final jsonList = jsonDecode(encodedList) as List<dynamic>;
    return fromJsonList(jsonList);
  }
}
