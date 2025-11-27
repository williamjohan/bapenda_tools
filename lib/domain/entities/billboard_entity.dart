// lib/domain/entities/billboard_entity.dart
import 'package:equatable/equatable.dart';

class BillboardEntity extends Equatable {
  // Identitas dan Informasi Utama (Sesuai API)
  final String id; // Dari noFormulir
  final String name; // Dari isiReklame
  final String type; // Dari nmJenis
  final String address; // Dari alamatReklame
  final String detailLocation; // Dari detilLokasi
  final String status; // Dari status

  // Status dan Tanggal
  final bool isActive; // Status aktif
  final bool isExpired; // Status kadaluarsa
  final DateTime startDate; // Dari tglMulaiBerlaku
  final DateTime endDate; // Dari tglAkhirBerlaku

  // Media dan Lokasi (Meskipun API tidak mengirim koordinat, ini perlu ada di Entity)
  final String imageUrl; // Base64 string yang sudah di-format sebagai data URL
  final double latitude; // Default 0.0 (Akan diisi nanti)
  final double longitude; // Default 0.0 (Akan diisi nanti)
  final double distance; // Default 0.0 (Akan diisi nanti)
  final double score; // Default 0.0 (Akan diisi nanti)

  const BillboardEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.detailLocation,
    required this.isActive,
    required this.isExpired,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.status,
    required this.score,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    address,
    detailLocation,
    isActive,
    isExpired,
    startDate,
    endDate,
    imageUrl,
    latitude,
    longitude,
    distance,
    status,
    score,
  ];
}
