// lib/data/models/billboard_model.dart
import '../../domain/entities/billboard_entity.dart';

class BillboardModel {
  final String id;
  final String name;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double distance; // Asumsi API mengembalikan dalam meter/km
  final String ownerName;
  final int status; // Asumsi API mengembalikan 1=Active, 0=Inactive
  final String photoUrl;

  const BillboardModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.ownerName,
    required this.status,
    required this.photoUrl,
  });

  // Nanti: factory BillboardModel.fromJson(Map<String, dynamic> json) { ... }

  // Fungsi PENTING: Mapping Model ke Entity
  BillboardEntity toEntity() {
    return BillboardEntity(
      id: id,
      name: name,
      type: type,
      address: address,
      latitude: latitude,
      longitude: longitude,
      // Lakukan konversi data mentah di sini:
      distanceKm: distance,
      owner: ownerName,
      isActive: status == 1, // Konversi int (0/1) ke bool (true/false)
      imageUrl: photoUrl,
    );
  }
}
