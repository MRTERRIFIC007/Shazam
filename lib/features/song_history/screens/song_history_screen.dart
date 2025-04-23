import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shazam/services/models/song_history_model.dart';
import 'package:shazam/viewmodels/song_history_vm.dart';
import 'package:shazam/song_screen.dart';
import 'package:shazam/services/models/deezer_song_model.dart';
import 'package:shazam/core/widgets/dots_painter.dart';
import 'package:shazam/features/song_history/widgets/history_list_item.dart';
import 'dart:ui';

class SongHistoryScreen extends ConsumerWidget {
  const SongHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(songHistoryProvider);

    // Set status bar color to transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFF051426),
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF042442),
      appBar: AppBar(
        title: const Text(
          'Your Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadSongHistory(),
            tooltip: 'Refresh',
          ),
          if (viewModel.songHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearHistoryDialog(context, viewModel),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient - match with home screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0E5CAD),
                  const Color(0xFF042442),
                  const Color(0xFF051426),
                ],
              ),
            ),
          ),

          // Background dots pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotsPainter(
                opacity: 0.08,
                dotCount: 120,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: _buildBody(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SongHistoryViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading songs...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              onPressed: () => viewModel.loadSongHistory(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.songHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/shazam-logo.png',
              width: 100,
              height: 100,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'No songs in history yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tap the Shazam button to start recognizing songs around you',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.music_note),
              label: const Text('Start Listening'),
            ),
          ],
        ),
      );
    }

    // Group songs by date for better organization
    Map<String, List<SongHistoryItem>> groupedSongs = {};
    for (var item in viewModel.songHistory) {
      final date = _formatDate(item.timestamp);
      if (!groupedSongs.containsKey(date)) {
        groupedSongs[date] = [];
      }
      groupedSongs[date]!.add(item);
    }

    // Convert to list for ListView.builder
    List<MapEntry<String, List<SongHistoryItem>>> dateGroups =
        groupedSongs.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: dateGroups.length,
      itemBuilder: (context, groupIndex) {
        final dateGroup = dateGroups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                dateGroup.key,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Songs for this date
            ...dateGroup.value.asMap().entries.map((entry) {
              final index = viewModel.songHistory.indexOf(entry.value);
              return HistoryListItem(
                historyItem: entry.value,
                index: index,
                onRemove: viewModel.removeSongFromHistory,
              );
            }).toList(),

            // Divider between date groups
            if (groupIndex < dateGroups.length - 1)
              Divider(
                color: Colors.white.withOpacity(0.1),
                height: 32,
                indent: 70,
                endIndent: 16,
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  void _showClearHistoryDialog(
      BuildContext context, SongHistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1A30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text(
              'Clear History',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear your entire song history?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              viewModel.clearSongHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete_sweep,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      const Text('History cleared'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
