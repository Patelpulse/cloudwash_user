import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String? imageSource;
  final double size;
  final BoxBorder? border;
  final String fallbackUrl;

  const ProfileImage({
    super.key,
    required this.imageSource,
    this.size = 80,
    this.border,
    this.fallbackUrl = 'https://i.pravatar.cc/150?u=user_cloudwash',
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider provider;
    
    if (imageSource == null || imageSource!.isEmpty) {
      provider = NetworkImage(fallbackUrl);
    } else if (imageSource!.startsWith('data:image')) {
      try {
        final base64String = imageSource!.split(',').last;
        provider = MemoryImage(base64Decode(base64String));
      } catch (e) {
        provider = NetworkImage(fallbackUrl);
      }
    } else if (imageSource!.startsWith('http')) {
      provider = NetworkImage(imageSource!);
    } else {
      // Handle other potential formats or assume it's a URL
      provider = NetworkImage(imageSource!);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Silently fail and fallback to placeholder if needed
          },
        ),
      ),
    );
  }
}
