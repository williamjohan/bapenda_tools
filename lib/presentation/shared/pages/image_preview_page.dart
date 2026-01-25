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
      onTap: () => Navigator.pop(context), // Tap layar untuk tutup
      child: Scaffold(
        backgroundColor: Colors.black, // Background hitam pekat
        // AppBar transparan (opsional)
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
              maxScale: 4.0, // Zoom sampai 4x
              child: Image(
                image: imageProvider, // ✅ Render dari provider
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
