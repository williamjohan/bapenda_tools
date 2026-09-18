// import 'package:bapendacore/presentation/features/camera/widgets/capture_action_bar.dart';
// import 'package:bapendacore/presentation/features/camera/widgets/processing_overlay_widget.dart'; // Jangan lupa import ini
// import 'package:bapendacore/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../cubit/camera_cubit.dart';
// import '../cubit/camera_state.dart';
// import '../widgets/camera_error_view.dart';
// import '../widgets/camera_view.dart';

// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     context.read<CameraCubit>().start();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final cubit = context.read<CameraCubit>();
//     final cameraState = cubit.state;

//     bool isBusy =
//         cameraState is CameraCapturing || cameraState is CameraProcessing;

//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//         if (!isBusy) {
//           cubit.onAppPaused();
//         }
//         break;

//       case AppLifecycleState.resumed:
//         if (!isBusy) {
//           cubit.onAppResumed();
//         }
//         break;

//       default:
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: BlocConsumer<CameraCubit, CameraState>(
//         listener: (context, state) {
//           // 1. Handle Navigasi Sukses
//           if (state is CameraCaptureSuccess) {
//             final cameraCubit = context.read<CameraCubit>();
//             context
//                 .pushNamed(
//                   AppRoutes.results,
//                   extra: {
//                     'imagePath': state.imagePath,
//                     'latitude': state.latitude,
//                     'longitude': state.longitude,
//                   },
//                 )
//                 .then((_) {
//                   // Opsional: Restart kamera saat kembali dari result page
//                   cameraCubit.start();
//                 });
//           }

//           // 2. Handle Error (GPS Mati / Timeout)
//           if (state is CameraFailure) {
//             // Cek jika errornya spesifik GPS Disabled
//             if (state.message == "GPS_DISABLED") {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text("GPS Wajib Aktif. Mohon nyalakan GPS."),
//                   action: SnackBarAction(
//                     label: "SETTINGS",
//                     onPressed: () => Geolocator.openLocationSettings(),
//                   ),
//                   duration: const Duration(seconds: 4),
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text(state.message)));
//             }
//           }
//         },
//         builder: (context, state) {
//           // A. Handle Permission Error
//           if (state is CameraPermissionDenied) {
//             return CameraErrorView(
//               onRetry: () => context.read<CameraCubit>().retry(),
//             );
//           }
//           if (state is CameraPermissionPermanentlyDenied) {
//             return CameraErrorView(
//               isPermanentlyDenied: true,
//               onOpenSettings: () => openAppSettings(),
//             );
//           }

//           // B. Handle Active Camera States (Ready, Focused, Capturing, Processing)
//           // Kita gunakan getter 'controller' dari cubit agar preview tidak hilang
//           // saat state berubah menjadi Capturing/Processing.
//           final cubit = context.read<CameraCubit>();
//           final controller = cubit.controller;

//           if (controller != null && controller.value.isInitialized) {
//             return Stack(
//               children: [
//                 // 1. Layer Paling Bawah: PREVIEW KAMERA
//                 CameraView(
//                   onScaleStart: () =>
//                       context.read<CameraCubit>().onScaleStart(),
//                   controller: controller,
//                   onScaleUpdate: (details) =>
//                       cubit.onScaleUpdate(details.scale),
//                   onTapToFocus: (details, size) => cubit.onTapToFocus(
//                     tapPosition: details.localPosition,
//                     previewSize: size,
//                   ),
//                 ),

//                 // 2. Layer Overlay: FOCUS INDICATOR (Kotak Kuning)
//                 // Hanya muncul jika state spesifik CameraFocused
//                 if (state is CameraFocused)
//                   Positioned(
//                     top: state.focusPoint.dy - 20,
//                     left: state.focusPoint.dx - 20,
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.yellow, width: 2),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                   ),

//                 // 3. Layer Kontrol: ACTION BAR (Flash, Shutter)
//                 CaptureActionBar(
//                   // Ambil flashMode dari state jika ada, atau default ke off
//                   flashMode: (state is CameraReady)
//                       ? state.flashMode
//                       : (state is CameraFocused)
//                       ? state.flashMode
//                       : FlashMode.off,
//                   // Disable tombol saat capturing/processing
//                   isLoading: state is CameraCapturing,
//                   isDisabled:
//                       state is CameraCapturing || state is CameraProcessing,
//                   onToggleFlash: cubit.toggleFlashMode,
//                   onCapture: cubit.capture,
//                 ),

//                 // 4. Layer Paling Atas: LOADING OVERLAY
//                 if (state is CameraProcessing)
//                   ProcessingOverlayWidget(message: state.message),
//               ],
//             );
//           }

//           // C. Fallback Loading (Saat inisialisasi awal)
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.white),
//           );
//         },
//       ),
//     );
//   }
// }
