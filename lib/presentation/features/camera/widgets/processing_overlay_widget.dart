import 'package:flutter/material.dart';

class ProcessingOverlayWidget extends StatelessWidget {
  final String message;

  const ProcessingOverlayWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isPhotoProcess = message.toLowerCase().contains("foto");

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Visual Inti: Stack Loading & Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  // Lingkaran Loading
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 5,
                      backgroundColor: Colors.white24,
                    ),
                  ),

                  // Ikon Tengah (Dinamis dengan Animasi)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                    child: Icon(
                      isPhotoProcess
                          ? Icons.photo_library_rounded
                          : Icons.gps_fixed,
                      key: ValueKey<bool>(isPhotoProcess),
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Judul Besar
              const Text(
                "Mohon Menunggu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Subteks (Dinamis dari Parent)
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
