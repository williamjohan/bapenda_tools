import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImagePreviewPage extends StatelessWidget {
  final Uint8List imageBytes;
  final String tag;

  const ImagePreviewPage({
    super.key,
    required this.imageBytes,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Tap anywhere to close
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        body: Center(
          child: Hero(
            tag: tag,
            child: InteractiveViewer(child: Image.memory(imageBytes)),
          ),
        ),
      ),
    );
  }
}
