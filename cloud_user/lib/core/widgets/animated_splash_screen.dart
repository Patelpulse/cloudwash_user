import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final Future<void> Function()? loadData;

  const AnimatedSplashScreen({
    super.key,
    required this.onAnimationComplete,
    this.loadData,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Start animation and loading
    _startEverything();
  }

  Future<void> _startEverything() async {
    // Start visual animation
    _logoController.forward();

    // Minimum splash duration
    final minDuration = Future.delayed(const Duration(milliseconds: 2500));

    // Data loading (if provided)
    final dataLoading = widget.loadData?.call() ?? Future.value();

    // Wait for BOTH to finish
    await Future.wait([minDuration, dataLoading]);

    if (mounted) {
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated particles background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleController.value),
                size: Size.infinite,
              );
            },
          ),

          // Logo
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _logoRotation.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6C63FF,
                                  ).withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                            ).createShader(bounds),
                            child: const Text(
                              'CloudWash',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your Laundry, Simplified',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue + i / 30) % 1.0;

      final opacity = (math.sin(offset * math.pi * 2) * 0.3 + 0.2);
      paint.color = Color(0xFF6C63FF).withOpacity(opacity);

      final radius = 2.0 + random.nextDouble() * 3.0;
      final particleY = y + (math.sin(offset * math.pi * 2) * 20);

      canvas.drawCircle(Offset(x, particleY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
