import 'dart:convert';

class Song {
  final int id;
  final String title;
  final String artist;
  final String? albumTitle;
  final String? albumCover;
  final String? previewUrl;
  final int? duration;
  final String? link;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumTitle,
    this.albumCover,
    this.previewUrl,
    this.duration,
    this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumTitle': albumTitle,
      'albumCover': albumCover,
      'previewUrl': previewUrl,
      'duration': duration,
      'link': link,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      albumTitle: json['albumTitle'],
      albumCover: json['albumCover'],
      previewUrl: json['previewUrl'],
      duration: json['duration'],
      link: json['link'],
    );
  }

  factory Song.fromDeezerModel(dynamic deezerModel) {
    return Song(
      id: deezerModel.id ?? 0,
      title: deezerModel.title ?? 'Unknown Title',
      artist: deezerModel.artist?.name ?? 'Unknown Artist',
      albumTitle: deezerModel.album?.title,
      albumCover: deezerModel.album?.coverMedium,
      previewUrl: deezerModel.preview,
      duration: deezerModel.duration,
      link: deezerModel.link,
    );
  }

  @override
  String toString() {
    return 'Song{id: $id, title: $title, artist: $artist}';
  }
}
