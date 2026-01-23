import 'package:equatable/equatable.dart';

abstract class UpdateProgressState extends Equatable {
  const UpdateProgressState();

  @override
  List<Object?> get props => [];
}

/// Dialog baru dibuka, belum mulai apa-apa
class UpdateInitial extends UpdateProgressState {}

/// Sedang download
class UpdateDownloading extends UpdateProgressState {
  final double progress; // 0.0 - 1.0
  final String message;

  const UpdateDownloading({required this.progress, required this.message});

  @override
  List<Object?> get props => [progress, message];
}

/// OTA sudah selesai download, masuk fase install
class UpdateInstalling extends UpdateProgressState {
  const UpdateInstalling();
}

/// Terjadi error (network, timeout, permission, dll)
class UpdateError extends UpdateProgressState {
  final String message;
  final bool canRetry;

  const UpdateError({required this.message, this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

/// Update selesai, dialog bisa ditutup
class UpdateCompleted extends UpdateProgressState {
  const UpdateCompleted();
}
