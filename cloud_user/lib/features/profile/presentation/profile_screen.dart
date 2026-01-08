import 'package:cloud_user/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:cloud_user/core/storage/token_storage.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:cloud_user/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please login to view profile')),
          );
        }

        Widget content = SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? MediaQuery.of(context).size.width * 0.1
                : 20,
            vertical: isDesktop ? 60 : 20,
          ),
          child: Column(
            children: [
              _buildProfileHeader(context, user, isDesktop),
              const SizedBox(height: 32),
              _buildProfileMenu(context, ref, isDesktop),
              const SizedBox(height: 32),
              _buildVersionInfo(),
            ],
          ),
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
              Container(
                width: isDesktop ? 100 : 80,
                height: isDesktop ? 100 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                    width: 4,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      user['profileImage'] ??
                          'https://i.pravatar.cc/150?u=user_cloudwash',
                    ),
                    fit: BoxFit.cover,
                  ),
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
      _buildMenuItem(
        context,
        icon: Icons.logout,
        title: 'Logout',
        subtitle: 'Sign out from account',
        color: Colors.red,
        onTap: () async {
          await ref.read(authRepositoryProvider).logout();
          ref.invalidate(authStateProvider);
          ref.invalidate(userProfileProvider);
          if (context.mounted) context.go('/');
        },
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
}
