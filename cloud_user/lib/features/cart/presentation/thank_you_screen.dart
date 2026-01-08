import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation for success
            SizedBox(
              height: 200,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_kz9pjc9k.json', // A nice success checkmark
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your booking has been received. Our professional team will arrive at your scheduled time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 48),
            _buildModernButton(
              context,
              'View My Bookings',
              () => context.go('/bookings'),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildModernButton(
              context,
              'Back to Home',
              () => context.go(kIsWeb ? '/' : '/home'),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      return WebLayout(child: content);
    }

    return Scaffold(backgroundColor: Colors.white, body: content);
  }

  Widget _buildModernButton(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    required bool isPrimary,
  }) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppTheme.primary : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppTheme.primary,
          elevation: isPrimary ? 4 : 0,
          side: isPrimary
              ? null
              : BorderSide(color: AppTheme.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
