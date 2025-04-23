import 'package:flutter/material.dart';
import 'package:shazam/services/models/song_history_model.dart';
import 'package:shazam/services/models/deezer_song_model.dart';
import 'package:shazam/song_screen.dart';

class HistoryListItem extends StatelessWidget {
  final SongHistoryItem historyItem;
  final int index;
  final Function(int) onRemove;

  const HistoryListItem({
    Key? key,
    required this.historyItem,
    required this.index,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final song = historyItem.song;
    final dateTime = historyItem.timestamp;
    final formattedTime =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key('history_item_$index'),
      background: Container(
        color: Colors.red.withOpacity(0.7),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onRemove(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                const Text('Song removed from history'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                // Undo functionality would go here
              },
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSongDetails(context, song),
          splashColor: Colors.blueAccent.withOpacity(0.1),
          highlightColor: Colors.blueAccent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Album cover
                Hero(
                  tag: 'album_cover_${song.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        song.albumCover != null && song.albumCover!.isNotEmpty
                            ? Image.network(
                                song.albumCover!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildAlbumCoverPlaceholder();
                                },
                              )
                            : _buildAlbumCoverPlaceholder(),
                  ),
                ),

                const SizedBox(width: 16),

                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Time and action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCoverPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[700]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white54,
        size: 24,
      ),
    );
  }

  void _navigateToSongDetails(BuildContext context, dynamic song) {
    // Convert Song to DeezerSongModel for compatibility with SongScreen
    final deezerSong = DeezerSongModel(
      id: song.id,
      title: song.title,
      artist: Artist(name: song.artist),
      album: Album(
        title: song.albumTitle,
        coverMedium: song.albumCover,
      ),
      preview: song.previewUrl,
      duration: song.duration,
      link: song.link,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongScreen(song: deezerSong),
      ),
    );
  }
}
