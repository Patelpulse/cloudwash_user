import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_user/core/utils/logo_cache_utils.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Brand colors pulled from the CloudWash logo palette
const _brandPrimary = Color(0xFF3B82F6); // vivid blue
const _brandSecondary = Color(0xFF22D3EE); // cyan accent

class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final Future<void> Function()? loadData;
  final String? dynamicLogoUrl;

  const AnimatedSplashScreen({
    super.key,
    required this.onAnimationComplete,
    this.loadData,
    this.dynamicLogoUrl,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  static const double _logoWidth = 300;
  static const double _logoHeight = 120;

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
      duration: const Duration(milliseconds: 2500),
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

    // Minimum splash duration (1.5s for snappier feel)
    final minDuration = Future.delayed( Duration(seconds: 3));

    try {
      // Data loading (if provided)
      final dataLoading = widget.loadData?.call() ?? Future.value();

      // Wait for BOTH to finish
      await Future.wait([minDuration, dataLoading]);
    } catch (e) {
      debugPrint('⚠️ Splash Screen Error: $e');
      // Even if loading fails, wait for minimum duration to ensure smooth transition
      await minDuration;
    }

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
                                  color: _brandPrimary.withValues(alpha: 0.18),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: _buildSplashLogo(),
                          ),
                          const SizedBox(height: 30),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_brandPrimary, _brandSecondary],
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

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: const Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _brandPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
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

  Uint8List? _decodeDataImage(String imageUrl) {
    if (!imageUrl.startsWith('data:image')) return null;
    final commaIndex = imageUrl.indexOf(',');
    if (commaIndex == -1 || commaIndex >= imageUrl.length - 1) return null;
    try {
      return base64Decode(imageUrl.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _buildSplashLogo() {
    final logoUrl = (widget.dynamicLogoUrl ?? '').trim();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: logoUrl.isEmpty
          ? KeyedSubtree(
              key: const ValueKey('default_logo'),
              child: _buildDefaultLogo(),
            )
          : KeyedSubtree(
              key: ValueKey(logoUrl),
              child: _buildLogoFrame(
                _decodeDataImage(logoUrl) != null
                    ? Image.memory(
                        _decodeDataImage(logoUrl)!,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        withLogoCacheBust(logoUrl),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildDefaultLogo();
                        },
                        errorBuilder: (_, __, ___) => _buildDefaultLogo(),
                      ),
              ),
            ),
    );
  }

  Widget _buildLogoFrame(Widget child) {
    return SizedBox(width: _logoWidth, height: _logoHeight, child: child);
  }

  Widget _buildDefaultLogo() {
    return _buildLogoFrame(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
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
      paint.color = _brandPrimary.withValues(alpha: opacity);

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
