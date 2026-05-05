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
    this.fallbackUrl = 'https://i0.wp.com/e-quester.com/wp-content/uploads/2021/11/placeholder-image-person-jpg.jpg?fit=820%2C678&ssl=1',
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource == null || imageSource!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
          color: Colors.grey[100],
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Colors.grey[400],
        ),
      );
    }

    ImageProvider provider;
    if (imageSource!.startsWith('data:image')) {
      try {
        final base64String = imageSource!.split(',').last;
        provider = MemoryImage(base64Decode(base64String));
      } catch (e) {
        return _buildFallback();
      }
    } else {
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
            // Error handling handled by the widget structure
          },
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: Colors.grey[100],
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.grey[400],
      ),
    );
  }
}
