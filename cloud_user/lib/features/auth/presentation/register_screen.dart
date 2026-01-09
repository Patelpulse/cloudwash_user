import 'package:cloud_user/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:cloud_user/features/profile/presentation/providers/user_provider.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:cloud_user/core/widgets/animated_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 1;
  bool _isLoading = false;

  // Step 2 Data
  User? _firebaseUser;
  final _nameController = TextEditingController();
  String? _profileImageUrl;
  String? _base64Image;

  // Step 3 Data
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
          _profileImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();

      if (result != null && result.userCredential?.user != null) {
        if (result.isAlreadyRegistered) {
          // User already exists, redirect to Home
          if (mounted) {
            ref.invalidate(authStateProvider);
            ref.invalidate(userProfileProvider);
            context.go('/');
          }
        } else {
          // New user, go to Step 2
          setState(() {
            _firebaseUser = result.userCredential!.user;
            _nameController.text = _firebaseUser!.displayName ?? '';
            _profileImageUrl = _firebaseUser!.photoURL;
            _currentStep = 2;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCompleteRegistration() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String cleanPhone = _phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (cleanPhone.length > 10) {
        cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
      }

      await ref
          .read(authRepositoryProvider)
          .completeRegistration(
            uid: _firebaseUser!.uid,
            name: _nameController.text,
            email: _firebaseUser!.email!,
            phone: cleanPhone,
            password: _passwordController.text,
            profileImage: _base64Image ?? _profileImageUrl,
          );

      if (mounted) {
        ref.invalidate(authStateProvider);
        ref.invalidate(userProfileProvider);
        context.go('/');
      }
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      // Try to parse specific backend error message
      if (e.toString().contains('DioException')) {
        try {
          // Dynamic access to avoid strict type need without import
          final dynamic exception = e;
          if (exception.response?.data != null) {
            final data = exception.response.data;
            if (data is Map && data.containsKey('message')) {
              errorMessage = data['message'];
            } else if (data is String) {
              errorMessage = data;
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    Widget content = Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500 : double.infinity,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepIndicator()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0),
            const SizedBox(height: 40),
            _buildStepContent()
                .animate(key: ValueKey(_currentStep))
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ],
        ),
      ),
    );

    // For both Web and Mobile, we use the same focused layout
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(child: SingleChildScrollView(child: content)),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle(1, 'Identify'),
          _stepLine(1),
          _stepCircle(2, 'Profile'),
          _stepLine(2),
          _stepCircle(3, 'Security'),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isDone = _currentStep > step;

    return Column(
      children: [
        AnimatedContainer(
          duration: 300.ms,
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.grey.shade100,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isActive ? AppTheme.primary : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int step) {
    bool isActive = _currentStep > step;
    return Container(
      width: 40,
      height: 3,
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 20),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Hero(
          tag: 'auth_icon',
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dry_cleaning, size: 50, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Join Cloud Wash',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Fastest way to get expert laundry services.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    height: 24,
                  ),
            label: Text(
              'Sign up with Google',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: _base64Image != null
                    ? MemoryImage(base64Decode(_base64Image!.split(',').last))
                          as ImageProvider
                    : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null),
                child: (_base64Image == null && _profileImageUrl == null)
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Setup Profile',
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about yourself to personalize your experience',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        const SizedBox(height: 40),
        _buildTextField('Full Name', _nameController, Icons.person_outline),
        const SizedBox(height: 20),
        _buildTextField(
          'Email Address',
          TextEditingController(text: _firebaseUser?.email),
          Icons.email_outlined,
          enabled: false,
        ),
        const SizedBox(height: 48),
        _primaryButton('Continue', () => setState(() => _currentStep = 3)),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        Text(
          'Security & Contact',
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          'Mobile Number',
          _phoneController,
          Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Create Password',
          _passwordController,
          Icons.lock_outline,
          isPassword: true,
          obscureText: !_showPassword,
          onSuffixIconTap: () => setState(() => _showPassword = !_showPassword),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Confirm Password',
          _confirmPasswordController,
          Icons.lock_outline,
          isPassword: true,
          obscureText: !_showConfirmPassword,
          onSuffixIconTap: () =>
              setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
        const SizedBox(height: 48),
        _primaryButton('Register Now', _handleCompleteRegistration),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onSuffixIconTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? AppTheme.primary : Colors.grey,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: AppTheme.primary.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
