import 'package:flutter/material.dart';

/// Renders a local image asset so
/// every photo slot in the app behaves the same.
class RemoteImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const RemoteImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).colorScheme.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
