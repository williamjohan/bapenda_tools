// lib/domain/entities/billboard_entity.dart
import 'package:equatable/equatable.dart';

class BillboardEntity extends Equatable {
  final String id;
  final String name;
  final String type; // Billboard, Videotron, Spanduk, dll.
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm; // Jarak dari lokasi foto user
  final String owner;
  final bool isActive; // Status aktif / tidak (boolean yang bersih)
  final String imageUrl;

  const BillboardEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.owner,
    required this.isActive,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    address,
    latitude,
    longitude,
    distanceKm,
    owner,
    isActive,
    imageUrl,
  ];
}
