import 'package:flutter/material.dart';

class ImagePreviewPage extends StatelessWidget {
  // ✅ UPDATE: Gunakan ImageProvider agar fleksibel (Bisa File/Memory/Network)
  final ImageProvider imageProvider;
  final String tag;

  const ImagePreviewPage({
    super.key,
    required this.imageProvider, // ✅ Constructor minta ImageProvider
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        extendBodyBehindAppBar: true,
        body: Center(
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
