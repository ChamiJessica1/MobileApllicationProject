import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

/// Dynamic wave background with glowing orbs and shimmer effects
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _orbController;
  late AnimationController _shimmerController;

  final List<GlowingOrb> _orbs = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Orb floating animation
    _orbController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..repeat();

    // Shimmer effect animation
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Initialize glowing orbs
    _initOrbs();

    _orbController.addListener(() {
      setState(() {
        for (var orb in _orbs) {
          orb.update();
        }
      });
    });
  }

  void _initOrbs() {
    for (int i = 0; i < 8; i++) {
      _orbs.add(
        GlowingOrb(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 80 + 40,
          speedX: (_random.nextDouble() - 0.5) * 0.0003,
          speedY: (_random.nextDouble() - 0.5) * 0.0003,
          color: _getRandomColor(),
          pulseSpeed: _random.nextDouble() * 0.02 + 0.01,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.indigo,
      Colors.purple,
      Colors.blue,
      Colors.deepPurple,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _waveController.dispose();
    _orbController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E), // Deep indigo
                Color(0xFF4A148C), // Deep purple
                Color(0xFF311B92), // Dark purple
              ],
            ),
          ),
        ),

        // Animated waves
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(_waveController.value),
              child: Container(),
            );
          },
        ),

        // Glowing orbs with blur effect
        AnimatedBuilder(
          animation: _orbController,
          builder: (context, child) {
            return CustomPaint(
              painter: OrbPainter(_orbs, _shimmerController.value),
              child: Container(),
            );
          },
        ),

        // Shimmer overlay
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return CustomPaint(
              painter: ShimmerPainter(_shimmerController.value),
              child: Container(),
            );
          },
        ),

        // Your actual content
        widget.child,
      ],
    );
  }
}

/// Glowing orb object
class GlowingOrb {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  Color color;
  double pulseSpeed;
  double pulsePhase = 0;

  GlowingOrb({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
    required this.pulseSpeed,
  });

  void update() {
    x += speedX;
    y += speedY;
    pulsePhase += pulseSpeed;

    // Wrap around screen
    if (x < -0.1) x = 1.1;
    if (x > 1.1) x = -0.1;
    if (y < -0.1) y = 1.1;
    if (y > 1.1) y = -0.1;
  }
}

/// Wave painter for flowing background waves
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw multiple wave layers
    _drawWave(
      canvas,
      size,
      animationValue,
      0.3,
      Colors.indigo.withOpacity(0.2),
    );
    _drawWave(
      canvas,
      size,
      animationValue + 0.3,
      0.4,
      Colors.purple.withOpacity(0.15),
    );
    _drawWave(
      canvas,
      size,
      animationValue + 0.6,
      0.5,
      Colors.blue.withOpacity(0.1),
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double offset,
    double heightFactor,
    Color color,
  ) {
    final path = Path();
    final waveHeight = size.height * heightFactor;

    path.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final x = i;
      final y =
          size.height -
          waveHeight +
          sin((i / size.width * 4 * pi) + (offset * 2 * pi)) *
              (waveHeight * 0.3);

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

/// Orb painter with glow effects
class OrbPainter extends CustomPainter {
  final List<GlowingOrb> orbs;
  final double shimmerValue;

  OrbPainter(this.orbs, this.shimmerValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      final center = Offset(orb.x * size.width, orb.y * size.height);
      final pulseFactor = 1.0 + sin(orb.pulsePhase) * 0.2;
      final radius = orb.size * pulseFactor;

      // Outer glow
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius * 1.5,
          [
            orb.color.withOpacity(0.3),
            orb.color.withOpacity(0.1),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(center, radius * 1.5, glowPaint);

      // Core orb
      final orbPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            orb.color.withOpacity(0.6),
            orb.color.withOpacity(0.3),
            orb.color.withOpacity(0.1),
          ],
          [0.0, 0.6, 1.0],
        );

      canvas.drawCircle(center, radius, orbPaint);

      // Shimmer highlight
      final shimmerPaint = Paint()
        ..color = Colors.white.withOpacity(0.3 * sin(shimmerValue * pi))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        radius * 0.3,
        shimmerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(OrbPainter oldDelegate) => true;
}

/// Shimmer overlay painter
class ShimmerPainter extends CustomPainter {
  final double animationValue;

  ShimmerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(-size.width * 0.5 + (animationValue * size.width * 1.5), 0),
        Offset(
          size.width * 0.5 + (animationValue * size.width * 1.5),
          size.height,
        ),
        [
          Colors.transparent,
          Colors.white.withOpacity(0.05),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) => true;
}
