import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shazam/song_screen.dart';
import 'package:shazam/viewmodels/home_vm.dart';
import 'package:shazam/core/widgets/dots_painter.dart';
import 'dart:ui';

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(homeViewModel);
    final size = MediaQuery.of(context).size;

    // Set status bar color to transparent
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    // Use hooks for animation controllers
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final pulseAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Wave animation for when listening
    final waveController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );

    final waveAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: waveController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Apply animations with proper cleanup to avoid double dispose
    useEffect(() {
      // Start the pulse animation
      animationController.repeat(reverse: true);

      // Only manage waveController here, don't return its dispose
      if (vm.isRecognizing) {
        waveController.repeat();
      } else {
        waveController.reset();
      }

      // Return disposal for just the animationController
      return () {
        // No disposal needed here - Flutter Hooks handles it
      };
    }, [vm.isRecognizing]);

    return Consumer(builder: (context, ref, _) {
      ref.listen<HomeViewModel>(homeViewModel, (previous, next) {
        if (next.success) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SongScreen(
                        song: next.currentSong!,
                      )));
        }
      });

      return Scaffold(
        body: Stack(
          children: [
            // Background gradient - classic Shazam blue shade
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0E5CAD),
                    Color(0xFF042442),
                    Color(0xFF051426),
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

            // Optional: subtle light rays when recognizing
            if (vm.isRecognizing)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15 * waveAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.blue.shade300,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Shazam brand area
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Transform.scale(
                            scale: vm.isRecognizing ? 1.0 : pulseAnimation,
                            child: Image.asset(
                              'assets/images/shazam-logo.png',
                              width: 80,
                              height: 80,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Shazam',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Error message area
                    if (vm.errorMessage != null && !vm.isRecognizing)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade300, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  vm.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (vm.errorMessage != null && !vm.isRecognizing)
                      const SizedBox(height: 20),

                    // Main recognition area
                    Column(
                      children: [
                        // Status text with animated transition
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: vm.isRecognizing
                              ? Column(
                                  key: const ValueKey('listening'),
                                  children: [
                                    Text(
                                      'Listening...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Hold your phone close to the music',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Tap to Shazam',
                                  key: const ValueKey('tap'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 40),

                        // Main recognition button
                        AvatarGlow(
                          endRadius: 120.0,
                          animate: vm.isRecognizing,
                          glowColor: Colors.blue.shade400,
                          child: GestureDetector(
                            onTap: () => vm.isRecognizing
                                ? vm.stopRecognizing()
                                : vm.startRecognizing(),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Material(
                                shape: CircleBorder(),
                                elevation: 8,
                                color: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.all(24),
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1E88E5),
                                        Color(0xFF0D47A1),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child: vm.isRecognizing
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Animated waves (simulated with circles)
                                                ...List.generate(3, (index) {
                                                  return Opacity(
                                                    opacity:
                                                        (1 - (index * 0.3)),
                                                    child: AnimatedContainer(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      width: 60.0 +
                                                          (index *
                                                              15 *
                                                              waveAnimation),
                                                      height: 60.0 +
                                                          (index *
                                                              15 *
                                                              waveAnimation),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(0.6 -
                                                                  (index *
                                                                      0.15)),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                                Icon(
                                                  Icons.mic,
                                                  color: Colors.white,
                                                  size: 50,
                                                ),
                                              ],
                                            )
                                          : Image.asset(
                                              'assets/images/shazam-logo.png',
                                              width: 70,
                                              height: 70,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Tip text at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Text(
                            vm.isRecognizing
                                ? 'Tap to cancel'
                                : 'Identify songs playing around you',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!vm.isRecognizing)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'or from this device',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
