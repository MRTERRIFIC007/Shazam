import 'package:flutter/material.dart';
import 'package:shazam/services/models/deezer_song_model.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shazam/services/favorites_service.dart';

class SongScreen extends StatefulWidget {
  final DeezerSongModel song;
  const SongScreen({Key? key, required this.song}) : super(key: key);

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPlaying = false;
  bool _isFavorite = false;
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFavorite = await _favoritesService.isFavorite(widget.song.id ?? 0);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesService.removeFromFavorites(widget.song.id ?? 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } else {
      await _favoritesService.addToFavorites(widget.song);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '0:00';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _shareSong() async {
    if (widget.song.title == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share song')),
      );
      return;
    }

    String artistName = widget.song.artist?.name ?? 'Unknown Artist';
    String songTitle = widget.song.title ?? 'Unknown Title';
    String? albumTitle = widget.song.album?.title;
    String? songLink = widget.song.link;

    String shareText = 'Check out this song I discovered with Shazam!\n\n'
        '🎵 $songTitle by $artistName';

    if (albumTitle != null) {
      shareText += '\n💿 Album: $albumTitle';
    }

    if (songLink != null) {
      shareText += '\n\nListen here: $songLink';
    }

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final coverUrl = widget.song.album?.coverXl ??
        widget.song.album?.coverBig ??
        widget.song.album?.coverMedium ??
        '';

    return Scaffold(
      body: Stack(
          children: [
          // Blurred background
          if (coverUrl.isNotEmpty)
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                  image: NetworkImage(coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

          // Dark gradient overlay
                    Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
                      child: Column(
                        children: [
                // App Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'MATCHED',
                                style: TextStyle(
                                    color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Album Art
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          coverUrl,
                          width: size.width * 0.7,
                          height: size.width * 0.7,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: size.width * 0.7,
                              height: size.width * 0.7,
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note,
                                  size: 80, color: Colors.white54),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Song Details
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Song title
                              Text(
                                widget.song.title ?? 'Unknown Title',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 8),

                              // Artist name
                              Text(
                                widget.song.artist?.name ?? 'Unknown Artist',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Album name
                              if (widget.song.album?.title != null)
                                Text(
                                  widget.song.album?.title ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),

                              // Duration
                              if (widget.song.duration != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 16,
                                          color: Colors.white.withOpacity(0.6)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDuration(
                                            widget.song.duration as int?),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 40),

                              // Player controls
                              if (widget.song.preview != null)
                                Column(
                                  children: [
                                    // Progress bar
                                    Container(
                                      height: 4,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: size.width *
                                                0.3, // Simulated progress
                                            height: 4,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.blue,
                                                  Colors.purple
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Play button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.blue,
                                                Colors.purple
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(32),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              onTap: () {
                                                setState(() {
                                                  _isPlaying = !_isPlaying;
                                                });
                                                // TODO: Implement audio playing logic
                                              },
                                              child: Icon(
                                                _isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                size: 32,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 24),

                              // Action buttons
                              _buildActionButtons(),

                              // Add bottom padding for better scrolling
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          icon: Icons.share,
          label: 'Share',
          onTap: _shareSong,
        ),
        _actionButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          label: _isFavorite ? 'Liked' : 'Like',
          color: _isFavorite ? Colors.red : null,
          onTap: _toggleFavorite,
        ),
        _actionButton(
          icon: Icons.open_in_new,
          label: 'Open',
          onTap: () => _launchURL(widget.song.link),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color ?? Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
