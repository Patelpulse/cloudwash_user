import 'package:cloud_user/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:cloud_user/core/storage/token_storage.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:cloud_user/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_user/core/widgets/auth_required_placeholder.dart';
import 'package:cloud_user/core/widgets/profile_image.dart';

import '../../cart/data/cart_provider.dart';
import '../../location/data/address_provider.dart' show selectedAddressProvider, userAddressesProvider;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const AuthRequiredPlaceholder(
            title: 'Your Profile',
            message: 'Sign in to manage your addresses, view notifications, and update your personal information.',
            icon: Icons.person_outline,
          );
        }

        Widget content = Stack(
          children: [
            SingleChildScrollView(
              physics: kIsWeb ? const NeverScrollableScrollPhysics() : null,
              padding: EdgeInsets.only(
                left: isDesktop ? 32 : 20,
                right: isDesktop ? 32 : 20,
                top: isDesktop ? 32 : 16,
                bottom: isDesktop ? 100 : 120, // Extra bottom padding for bottom bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, user, isDesktop),
                  const SizedBox(height: 32),
                  _buildProfileMenu(context, ref, isDesktop),
                  const SizedBox(height: 32),
                  _buildVersionInfo(),
                ],
              ),
            ),
            if (_isDeleting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );

        if (kIsWeb) {
          return WebLayout(child: content);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(child: content),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    Map<String, dynamic> user,
    bool isDesktop,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ProfileImage(
                imageSource: user['profileImage'],
                size: isDesktop ? 100 : 80,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  width: 4,
                ),
              ),
              InkWell(
                onTap: () => context.push('/edit-profile'),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user['phone'] ?? 'No phone',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['email'] ?? 'No email',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            ElevatedButton(
              onPressed: () => context.push('/edit-profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(
    BuildContext context,
    WidgetRef ref,
    bool isDesktop,
  ) {
    final menuItems = [
      _buildMenuItem(
        context,
        icon: Icons.person_outline,
        title: 'Personal Info',
        subtitle: 'Profile, name, and phone',
        onTap: () => context.push('/personal-info'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.location_on_outlined,
        title: 'Manage Addresses',
        subtitle: 'Home, work, and others',
        onTap: () => context.push('/addresses'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Alerts and updates',
        onTap: () => context.push('/notifications'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'FAQs and contact us',
        onTap: () => context.push('/help'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.security_outlined,
        title: 'Privacy Policy',
        subtitle: 'Your data and safety',
        onTap: () => context.push('/privacy'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.child_care_outlined,
        title: 'Child Protection',
        subtitle: 'Our safety commitment',
        onTap: () => context.push('/child-protection'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.assignment_return_outlined,
        title: 'Refund Policy',
        subtitle: 'Return and refund rules',
        onTap: () => context.push('/refund-policy'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.description_outlined,
        title: 'Terms & Conditions',
        subtitle: 'Rules of the platform',
        onTap: () => context.push('/terms'),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: Colors.redAccent, thickness: 0.5),
      ),
      _buildMenuItem(
        context,
        icon: Icons.delete_forever_outlined,
        title: 'Delete Account',
        subtitle: 'Permanently remove your data',
        color: Colors.red.shade700,
        onTap: () => _showDeleteAccountDialog(context, ref),
      ),
      _buildMenuItem(
        context,
        icon: Icons.logout,
        title: 'Logout',
        subtitle: 'Sign out from account',
        color: Colors.red,
        onTap: () => _showLogoutDialog(context, ref),
      ),
    ];

    if (!isDesktop) {
      return Column(
        children: menuItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: item,
              ),
            )
            .toList(),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: menuItems,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color ?? Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'Cloud Wash Plus',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.1 • Crafted with ❤️',
          style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from Cloud Wash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              
              // Perform logout and state reset BEFORE navigating away
              await ref.read(authRepositoryProvider).logout();
              
              // Comprehensive state reset
              ref.invalidate(authStateProvider);
              ref.invalidate(userProfileProvider);
              ref.invalidate(userAddressesProvider);
              ref.invalidate(selectedAddressProvider);
              ref.read(cartProvider.notifier).clearCart();
              
              // Navigate after cleanup
              if (context.mounted) {
                context.go('/');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, including order history and addresses, will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Pop confirmation dialog
              
              setState(() => _isDeleting = true);

              try {
                await ref.read(authRepositoryProvider).deleteAccount();
                
                // State changes in AuthRepository will cause this widget to rebuild
                // as AuthRequiredPlaceholder, effectively removing the _isDeleting overlay.

                // Comprehensive state reset
                ref.invalidate(authStateProvider);
                ref.invalidate(userProfileProvider);
                ref.invalidate(userAddressesProvider);
                ref.invalidate(selectedAddressProvider);
                ref.read(cartProvider.notifier).clearCart();
                
                if (mounted) {
                  context.go('/');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isDeleting = false);
                  
                  final messenger = ScaffoldMessenger.of(context);
                  String message = e.toString();
                  
                  if (message.contains('requires-recent-login')) {
                    message = 'For security, please logout and login again before deleting your account.';
                  } else if (e is FirebaseAuthException) {
                    message = e.message ?? 'An error occurred during account deletion.';
                  }

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
