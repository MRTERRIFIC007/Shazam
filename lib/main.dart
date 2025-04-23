import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shazam/core/navigation/app_navigation.dart';
import 'package:shazam/web_home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shazam/services/auth_service.dart';
import 'package:shazam/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Request microphone permission if not on web
  if (!kIsWeb) {
    final status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      await Permission.microphone.request();
      final newStatus = await Permission.microphone.status;
      print('Microphone permission status: $newStatus');
    } else {
      print('Microphone permission already granted');
    }
  }

  runApp(ProviderScope(child: MyApp()));
}

// Provider for authentication state
final authStateProvider = StateProvider<bool>((ref) => false);
final userProvider = StateProvider<User?>((ref) => null);

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize AuthService
    final authService = AuthService();

    // Check authentication state
    authService.authStateChanges().listen((User? user) {
      ref.read(authStateProvider.notifier).state = user != null;
      ref.read(userProvider.notifier).state = user;
    });

    // Get current auth state
    final isAuthenticated = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shazam Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: kIsWeb
          ? WebHomePage()
          : isAuthenticated
              ? const AppNavigation()
              : const LoginScreen(),
    );
  }
}
