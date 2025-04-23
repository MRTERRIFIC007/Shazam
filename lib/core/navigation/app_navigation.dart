import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shazam/home.dart';
import 'package:shazam/features/song_history/screens/song_history_screen.dart';
import 'package:shazam/screens/favorites_screen.dart';
import 'package:shazam/screens/profile_screen.dart';

final navigationProvider = StateProvider<int>((ref) => 0);

class AppNavigation extends HookConsumerWidget {
  const AppNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    // Define the pages
    final pages = [
      HomePage(),
      const SongHistoryScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(navigationProvider.notifier).state = index,
        backgroundColor: Color(0xFF042442),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed, // Required for 4+ items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Shazam',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
