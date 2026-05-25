import 'dart:convert';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CustomImage(
    this.imageUrl, {
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64String = imageUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder,
        );
      } catch (e) {
        if (errorBuilder != null) {
          return errorBuilder!(context, e, null);
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }
    } else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }
}

ImageProvider getCustomImageProvider(String imageUrl) {
  if (imageUrl.startsWith('data:image/')) {
    try {
      final base64String = imageUrl.split(',').last;
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (_) {
      return const AssetImage('assets/map.png'); // Fallback
    }
  } else if (imageUrl.startsWith('http')) {
    return NetworkImage(imageUrl);
  } else {
    return const AssetImage('assets/map.png');
  }
}
