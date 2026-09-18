// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class CameraView extends StatelessWidget {
//   final CameraController controller;
//   final VoidCallback onScaleStart;
//   final void Function(ScaleUpdateDetails) onScaleUpdate;
//   final void Function(TapDownDetails, Size previewSize) onTapToFocus;

//   const CameraView({
//     super.key,
//     required this.controller,
//     required this.onScaleStart,
//     required this.onScaleUpdate,
//     required this.onTapToFocus,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = constraints.maxWidth;
//         final screenHeight = constraints.maxHeight;

//         // 1. HITUNG RASIO KAMERA
//         // Ambil aspect ratio dari controller
//         var cameraAspectRatio = controller.value.aspectRatio;

//         // Safety check (hindari pembagian 0)
//         if (cameraAspectRatio == 0) cameraAspectRatio = 1.0;

//         // Logic God Widget Lama:
//         // Karena orientasi portrait, rasio harus dibalik (1 / ratio).
//         // Misal kamera landscape 4:3 (1.33), maka portraitnya 3:4 (0.75).
//         final adjustedRatio = 1 / cameraAspectRatio;

//         // 2. HITUNG TINGGI YANG DIBUTUHKAN AGAR LEBAR PAS (MATCH WIDTH)
//         // Rumus: Height = Width / Ratio
//         final requiredHeight = screenWidth / adjustedRatio;

//         // 3. RENDER DENGAN FITTEDBOX
//         // FittedBox akan otomatis men-zoom in (scale up) kotak ini
//         // sampai menutupi seluruh layar (BoxFit.cover), TANPA merusak rasio.
//         return ClipRRect(
//           child: SizedBox.expand(
//             child: GestureDetector(
//               onScaleStart: (_) => onScaleStart(),
//               onScaleUpdate: onScaleUpdate,
//               onTapDown: (details) =>
//                   onTapToFocus(details, Size(screenWidth, screenHeight)),
//               child: FittedBox(
//                 fit: BoxFit.cover, // ✅ Kunci Full Screen tanpa gepeng
//                 child: SizedBox(
//                   width: screenWidth,
//                   height:
//                       requiredHeight, // ✅ KEMBALI KE LOGIC ASLI (Jangan di-clamp ke screenHeight!)
//                   child: CameraPreview(controller),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
