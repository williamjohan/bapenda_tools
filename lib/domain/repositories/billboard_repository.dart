import '../entities/billboard_entity.dart';

abstract class BillboardRepository {
  // 1. Fungsi untuk mendapatkan daftar reklame terdekat
  // Future<List<BillboardEntity>> getNearbyBillboards({
  //   required double latitude,
  //   required double longitude,
  // });

  // 2. Fungsi untuk mengunggah foto dan mendapatkan detail (proses utama)
  Future<List<BillboardEntity>> checkBillboardByPhoto({
    required String imagePath,
    required double latitude,
    required double longitude,
  });
}
