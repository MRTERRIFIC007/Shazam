import 'package:flutter/material.dart';
import 'package:shazam/models/song.dart';
import 'package:shazam/services/favorites_service.dart';
import 'package:shazam/services/models/deezer_song_model.dart';
import 'package:shazam/song_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Song> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final favorites = await _favoritesService.getFavorites();

    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Song song) async {
    await _favoritesService.removeFromFavorites(song.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from favorites'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            // Convert back to DeezerSongModel for re-adding
            final deezerModel = DeezerSongModel(
              id: song.id,
              title: song.title,
              artist: Artist(name: song.artist),
              album: song.albumTitle != null
                  ? Album(
                      title: song.albumTitle,
                      coverMedium: song.albumCover,
                    )
                  : null,
              duration: song.duration,
              preview: song.previewUrl,
              link: song.link,
            );
            await _favoritesService.addToFavorites(deezerModel);
            _loadFavorites();
          },
        ),
      ),
    );
    _loadFavorites();
  }

  Future<void> _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text('Are you sure you want to remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      await _favoritesService.clearFavorites();
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAllFavorites,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your favorite songs will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final song = _favorites[index];
                      return Dismissible(
                        key: Key('favorite_${song.id}'),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeFavorite(song),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: song.albumCover != null
                                ? Image.network(
                                    song.albumCover!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, _, __) =>
                                        _defaultAlbumArt(),
                                  )
                                : _defaultAlbumArt(),
                          ),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFavorite(song),
                          ),
                          onTap: () {
                            // Since we can't directly convert Song to DeezerSongModel,
                            // we'll create a simplified version for display
                            final deezerModel = DeezerSongModel(
                              id: song.id,
                              title: song.title,
                              artist: Artist(name: song.artist),
                              album: song.albumTitle != null
                                  ? Album(
                                      title: song.albumTitle,
                                      coverMedium: song.albumCover,
                                    )
                                  : null,
                              duration: song.duration,
                              preview: song.previewUrl,
                              link: song.link,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SongScreen(song: deezerModel),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _defaultAlbumArt() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: const Icon(Icons.music_note),
    );
  }
}
