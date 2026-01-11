// lib/domain/usecases/check_billboard_usecase.dart
import 'package:cekreklamemobile/domain/entities/billboard_entity.dart';
import 'package:cekreklamemobile/domain/repositories/billboard_repository.dart';

class CheckBillboardUseCase {
  final BillboardRepository repository;

  CheckBillboardUseCase(this.repository);

  // Use Case utama: mengambil daftar reklame terdekat berdasarkan koordinat.
  Future<List<BillboardEntity>> call({
    required String imagePath,
    required double latitude,
    required double longitude,
    void Function(double progress)? onProgress,
  }) async {
    // Di sini kita bisa menambahkan logika bisnis seperti validasi jarak/rate limit, dll.
    return await repository.checkReklameWithCoordinate(
      imagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      onProgress: onProgress,
    );
  }
}
