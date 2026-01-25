import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

enum NearbyStatus {
  initial,
  loading,
  active,
  error,
  permissionDenied,
  serviceDisabled,
  noInternet, // 👈 TAMBAHAN BARU: Level 3 Error
}

class NearbyState extends Equatable {
  final NearbyStatus status;
  final Position? currentPosition;
  final String? mapImageUrl;

  const NearbyState({
    this.status = NearbyStatus.initial,
    this.currentPosition,
    this.mapImageUrl,
  });

  @override
  List<Object?> get props => [status, currentPosition, mapImageUrl];

  // Helper copyWith
  NearbyState copyWith({
    NearbyStatus? status,
    Position? currentPosition,
    String? mapImageUrl,
  }) {
    return NearbyState(
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      mapImageUrl: mapImageUrl ?? this.mapImageUrl,
    );
  }
}
