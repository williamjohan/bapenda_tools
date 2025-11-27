import 'package:cekreklamemobile/core/utils/date_utils.dart';
import '../../domain/entities/billboard_entity.dart';

class BillboardModel {
  // Field persis seperti dari JSON API
  final String noFormulir;
  final String nmJenis;
  final String tglMulaiBerlaku; // String (API)
  final String tglAkhirBerlaku; // String (API)
  final String alamatReklame;
  final String detilLokasi;
  final String isiReklame;
  final String thumbnail; // Base64 String
  final String status;
  final double score;
  final double jarak;
  final double latitude;
  final double longitude;

  const BillboardModel({
    required this.noFormulir,
    required this.nmJenis,
    required this.tglMulaiBerlaku,
    required this.tglAkhirBerlaku,
    required this.alamatReklame,
    required this.detilLokasi,
    required this.isiReklame,
    required this.thumbnail,
    required this.status,
    required this.score,
    required this.jarak,
    required this.latitude,
    required this.longitude,
  });

  // Factory untuk memetakan dari JSON
  factory BillboardModel.fromJson(Map<String, dynamic> json) {
    // Memberikan nilai default String kosong jika null
    return BillboardModel(
      noFormulir: json['noFormulir'] as String? ?? '',
      nmJenis: json['nmJenis'] as String? ?? '',
      tglMulaiBerlaku: json['tglMulaiBerlaku'] as String? ?? '',
      tglAkhirBerlaku: json['tglAkhirBerlaku'] as String? ?? '',
      alamatReklame: json['alamatReklame'] as String? ?? '',
      detilLokasi: json['detilLokasi'] as String? ?? '',
      isiReklame: json['isiReklame'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      status: json['status'] as String? ?? 'Unknown',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      jarak: (json['jarak'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  BillboardEntity toEntity() {
    final startDate = safeParseDateTime(tglMulaiBerlaku);
    final endDate = safeParseDateTime(tglAkhirBerlaku);
    // final isActive = endDate.isAfter(DateTime.now());
    final imageUrlData = thumbnail.isNotEmpty
        ? 'data:image/png;base64,$thumbnail'
        : '';
    final bool isActiveStatus = status.toUpperCase() == 'AKTIF';
    final bool isExpiredStatus = status.toUpperCase() == 'EXPIRED';

    return BillboardEntity(
      id: noFormulir,
      name: isiReklame,
      type: nmJenis,
      address: alamatReklame,
      detailLocation: detilLokasi,
      isActive: isActiveStatus,
      isExpired: isExpiredStatus,
      startDate: startDate,
      endDate: endDate,
      imageUrl: imageUrlData,
      latitude: latitude,
      longitude: longitude,
      distance: jarak,
      score: score,
      status: status,
    );
  }
}
