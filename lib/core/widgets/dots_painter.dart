import 'package:flutter/material.dart';

class DotsPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final int dotCount;

  DotsPainter({
    this.color = Colors.white,
    this.opacity = 0.05,
    this.dotCount = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final random = DateTime.now().millisecondsSinceEpoch;

    // Draw random dots
    for (int i = 0; i < dotCount; i++) {
      final x = (random * (i + 1) % size.width).toDouble();
      final y = (random * (i + 2) % size.height).toDouble();
      final radius = (random % 3 + 1).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(DotsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.dotCount != dotCount;
  }
}
