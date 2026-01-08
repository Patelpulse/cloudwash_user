import 'dart:math';
import 'dart:ui';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base Color
            Container(color: Colors.white),

            // Animated Blobs
            _buildBlob(
              color: AppTheme.primary.withOpacity(0.12),
              size: 500,
              offset: Offset(
                100 * sin(_controller.value * 2 * pi),
                100 * cos(_controller.value * 2 * pi),
              ),
              alignment: Alignment.topLeft,
            ),
            _buildBlob(
              color: AppTheme.primary.withOpacity(0.08),
              size: 400,
              offset: Offset(
                -150 * cos(_controller.value * 2 * pi),
                150 * sin(_controller.value * 2 * pi),
              ),
              alignment: Alignment.bottomRight,
            ),
            _buildBlob(
              color: const Color(
                0xFF6366F1,
              ).withOpacity(0.06), // Complementary Indigo
              size: 450,
              offset: Offset(
                50 * sin(_controller.value * pi),
                -100 * cos(_controller.value * pi),
              ),
              alignment: Alignment.centerRight,
            ),

            // Blur Effect to create the mesh look
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // The actual content
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }

  Widget _buildBlob({
    required Color color,
    required double size,
    required Offset offset,
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
          ),
        ),
      ),
    );
  }
}
