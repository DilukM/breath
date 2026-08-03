import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Wraps [CachedNetworkImage] with a themed placeholder/error fallback so
/// every photo slot in the app behaves the same while the network image
/// loads (or fails, e.g. offline).
class RemoteImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const RemoteImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surface,
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}
