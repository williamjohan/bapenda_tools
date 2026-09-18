// // camera_state.dart
// import 'dart:ui';

// import 'package:camera/camera.dart';

// sealed class CameraState {}

// class CameraInitial extends CameraState {}

// class CameraPermissionRequesting extends CameraState {}

// class CameraLoading extends CameraState {}

// class CameraPermissionDenied extends CameraState {}

// class CameraPermissionPermanentlyDenied extends CameraState {}

// class CameraReady extends CameraState {
//   final CameraController controller;
//   final FlashMode flashMode;
//   final double zoom;
//   CameraReady(this.controller, this.flashMode, this.zoom);
// }

// class CameraCapturing extends CameraState {}

// class CameraProcessing extends CameraState {
//   final String message;
//   CameraProcessing(this.message);
// }

// class CameraFailure extends CameraState {
//   final String message;
//   CameraFailure(this.message);
// }

// class CameraFocused extends CameraState {
//   final CameraController controller;
//   final Offset focusPoint;
//   final FlashMode flashMode;
//   final double zoom;

//   CameraFocused({
//     required this.controller,
//     required this.focusPoint,
//     required this.flashMode,
//     required this.zoom,
//   });
// }

// class CameraCaptureSuccess extends CameraState {
//   final String imagePath;
//   final double latitude;
//   final double longitude;

//   CameraCaptureSuccess({
//     required this.imagePath,
//     required this.latitude,
//     required this.longitude,
//   });
// }
